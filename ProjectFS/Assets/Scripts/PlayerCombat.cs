using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEditor;
using UnityEngine.UI;
using TMPro;
using static UnityEditor.Experimental.GraphView.GraphView;

public class PlayerCombat : MonoBehaviour
{
    float rangeAttackTimer = 0;
    float meleeAttackTimer = 0;
    public float rangedChargeThresholdTime = 2;
    public float meleeChargeThresholdTime = 1;
    public GameObject lightProjectilePrefab;
    public GameObject chargedProjectilePrefab;
    public Transform launchTransform;
    public Camera cam;
    public Transform attackPoint;

    [Space(5)]
    public float lightAttackRange = 1;
    public float lightAttackDamage = 1;
    public float lightAttackKnockbackStrength = 5;
    public float lightAttackKnockbackStrengthUp = 1;

    [Space(5)]
    public float chargedAttackRange = 1;
    public float chargedAttackDamage = 1;
    public float chargedAttackStaminaDrain;
    public float chargedAttackKnockbackStrength = 5;
    public float chargedAttackKnockbackStrengthUp = 2;
    public float rangedDamage;

    float attackTimer = 0;
    public float attackPauseTime;
    public float attackAnimationDelay;
    public float speedWhileAttacking;

    [Space(5)]

    public LayerMask enemyLayers;

    public Transform aimTransform;
    float aimAngle = 0;
    [SerializeField] float aimSpeed;
    [SerializeField] float aimRadius;
    [SerializeField] float aimPanStart;
    [SerializeField] float aimPanEnd;
    private Vector3 mousePos;

    float aimTime;
    float aimTimer;
    float _aimPanStart;
    float _aimPanEnd;
    bool isAiming = false;
    bool canAttack;
    public float distanceFromCam;
    public float rangedAttackStaminaDrain;

    PlayerController playerController;
    public PlayerData playerData;
    [SerializeField] private Animator characterAnimator;

    [Space(5)]
    public Slider healthBarSlider;
    [Space(5)]
    public Slider staminaBarSlider;

    private LightProjectile lastProjectile;

    public int missileMode = 1;

    [SerializeField]
    private MissileModeUI[] missileModeOutlines;

    public Color activeMissileModeColor;
    public Color inactiveMissileModeColor;

    [Space(5)]
    private float startHealth;
    private float staminaTimer;
    public float staminaRegain;

    private Dictionary<KeyCode, int> missileModeKeys;

    public static PlayerCombat instance { get; private set; }

    private void Awake()
    {
        if (instance != null)
        {
            Debug.Log("More than one PlayerCombat");
        }
        instance = this;
    }

    void Start()
    {
        staminaTimer = 2;
        startHealth = healthBarSlider.value;
        playerController = GetComponent<PlayerController>();
        missileModeOutlines = Resources.FindObjectsOfTypeAll(typeof(MissileModeUI)) as MissileModeUI[];
        SetUpDictionaryKeys();
        missileMode = 1;
        SetMissileModeUI();
    }

    void Update()
    {
        Aim();
        if (!isAiming)
        {
            if (Input.GetKeyDown(KeyCode.R))
            {
                isAiming = true;
            }
            aimTransform.gameObject.GetComponentInChildren<MeshRenderer>().enabled = false;
        }
        else
        {
            aimTransform.gameObject.GetComponentInChildren<MeshRenderer>().enabled = true;
            if (Input.GetMouseButtonDown(1))
            {
                if (CheckStamina(rangedAttackStaminaDrain))
                {
                    LaunchProjectile();
                }

                isAiming = false;
            }
        }

        if (missileMode == 1)
        {
            if (Input.GetMouseButtonDown(0) && canAttack)
            {
                meleeAttackTimer += Time.deltaTime;
                characterAnimator.SetTrigger("attack");


            }
            else if (Input.GetMouseButtonDown(1) && canAttack && !isAiming)
            {
                characterAnimator.SetTrigger("chargedAttack");

            }
        }
        else if (missileMode == 2)
        {
            if (lastProjectile != null)
            {
                if (Input.GetMouseButtonDown(0))
                {
                    Teleport();
                }
            }
        }

        MissileModeInput();

        attackTimer += Time.deltaTime;

        if (staminaTimer >= 2 && staminaBarSlider.value <= 100)
        {
            RegainStamina();
        }

        staminaTimer += Time.deltaTime;
    }

    public void FixedUpdate()
    {
        if (characterAnimator.GetCurrentAnimatorStateInfo(0).IsName("Attack") || characterAnimator.GetCurrentAnimatorStateInfo(0).IsName("Attack"))
        {
            if (characterAnimator.GetCurrentAnimatorStateInfo(0).normalizedTime < 1.0f)
            {
                //playerController._runMaxSpeed = speedWhileAttacking;
                canAttack = false;
            }
        }
        else
        {
            canAttack = true;
            playerController._runMaxSpeed = playerData.runMaxSpeed;
        }
    }

    void LightMeleeAttack()
    {
        Collider[] enemiesHit = Physics.OverlapSphere(attackPoint.position, lightAttackRange, enemyLayers, QueryTriggerInteraction.Collide);

        foreach (Collider collider in enemiesHit)
        {
            if (collider.gameObject.GetComponent<Enemy>() != null)
            {
                Enemy enemy = collider.gameObject.GetComponent<Enemy>();

                enemy.LoseHealth(lightAttackDamage);

                if (enemy.rb != null)
                {
                    enemy.Knockback(transform, lightAttackKnockbackStrength, lightAttackKnockbackStrengthUp);
                }

            }
        }
    }

    void ChargedMeleeAttack()
    {

        Collider[] enemiesHit = Physics.OverlapSphere(attackPoint.position, chargedAttackRange, enemyLayers, QueryTriggerInteraction.Collide);

        foreach (Collider collider in enemiesHit)
        {
            if (collider.gameObject.GetComponent<Enemy>() != null)
            {
                Enemy enemy = collider.gameObject.GetComponent<Enemy>();

                enemy.LoseHealth(chargedAttackDamage);
                if (!enemy.knockbacked)
                {
                    enemy.Knockback(transform, chargedAttackKnockbackStrength, chargedAttackKnockbackStrengthUp);
                }

            }
        }
    }

    void LaunchProjectile()
    {
        GameObject lightProjectile = Instantiate(lightProjectilePrefab, launchTransform.position, Quaternion.identity);
        lastProjectile = lightProjectile.GetComponent<LightProjectile>();

        Vector3 mousePosInput = Input.mousePosition;
        mousePosInput.z = 20;
        mousePos = new Vector3(cam.ScreenToWorldPoint(mousePosInput).x, cam.ScreenToWorldPoint(mousePosInput).y, -4.74f);

        Vector3 direction = mousePos - lightProjectile.transform.position;

        lightProjectile.GetComponent<Rigidbody>().velocity = direction.normalized * lightProjectile.GetComponent<LightProjectile>().speed;
        characterAnimator.SetTrigger("attack");

    }

    void Aim()
    {
        mousePos = new Vector3(cam.WorldToScreenPoint(aimTransform.position).x, cam.WorldToScreenPoint(aimTransform.position).y, distanceFromCam);

        Vector3 direction = Input.mousePosition - mousePos;

        float angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg;

        aimTransform.rotation = Quaternion.AngleAxis(angle, Vector3.forward);
    }


    void Shield()
    {

    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.DrawWireSphere(attackPoint.position, lightAttackRange);
        Gizmos.DrawWireSphere(attackPoint.position, chargedAttackRange);
    }

    public void TakeDamage(float attackDamage)
    {
        healthBarSlider.value -= attackDamage;
        if (healthBarSlider.value <= 0)
        {
            StartCoroutine(PlayerInteraction.instance.DeathCondition());
        }
        characterAnimator.SetTrigger("hurt");
    }

    public void LoseStamina(float staminaAmount)
    {
        staminaBarSlider.value -= staminaAmount;
    }

    public bool CheckStamina(float staminaNeededForAction)
    {
        if (staminaNeededForAction > staminaBarSlider.value)
        {
            return false;
        }
        else
        {
            LoseStamina(staminaNeededForAction);
            staminaTimer = 0;
            return true;
        }
    }

    void RegainStamina()
    {
        staminaBarSlider.value += staminaRegain;
    }

    public void Teleport()
    {
        transform.position = lastProjectile.transform.position;
        Destroy(lastProjectile.gameObject);
    }

    public void GainHealth(float healthAmount)
    {
        if (healthBarSlider.value + healthAmount <= healthBarSlider.maxValue)
        {
            healthBarSlider.value += healthAmount;
        }
        else
        {
            healthBarSlider.value = healthBarSlider.maxValue;
        }
    }

    void SetMissileModeUI()
    {
        foreach (var item in missileModeOutlines)
        {
            if (missileMode == item.id)
            {
                item.SetColor(activeMissileModeColor);
            }
            else
            {
                item.SetColor(inactiveMissileModeColor);
            }
        }
    }

    private void SetUpDictionaryKeys()
    {
        missileModeKeys = new Dictionary<KeyCode, int>
        {
            { KeyCode.Alpha1, 1 }
        };
    }

    public void MissileModeInput()
    {
        foreach (var kvp in missileModeKeys)
        {
            missileModeOutlines[kvp.Value - 1].gameObject.SetActive(true);
            if (Input.GetKeyDown(kvp.Key))
            {
                missileMode = kvp.Value;
                SetMissileModeUI();
            }
        }
    }

    private void IncreaseMaxHealth()
    {
        healthBarSlider.maxValue += 15;
    }

    private void IncreaseMaxStamina()
    {
        staminaBarSlider.maxValue += 15;
    }

    public void IncreaseDamage(float _rangedDamage, float _lightAttackDamage, float _heavyAttackDamage)
    {
        rangedDamage += _rangedDamage;
        lightAttackDamage += _lightAttackDamage;
        chargedAttackDamage += _heavyAttackDamage;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "teleportUnlock")
        {
            missileModeKeys.Add(KeyCode.Alpha2, 2);
        }
        if(other.gameObject.tag == "healthUnlock")
        {
            IncreaseMaxHealth();
        }
        if(other.gameObject.tag == "staminaUnlock")
        {
            IncreaseMaxStamina();
        }
        if(other.gameObject.GetComponent<DamageUnlock>())
        {
            DamageUnlock damageParams = other.gameObject.GetComponent<DamageUnlock>();
            IncreaseDamage(damageParams.rangedDamage, damageParams.lightAttackDamage, damageParams.heavyAttackDamage);
        }

    }
}
