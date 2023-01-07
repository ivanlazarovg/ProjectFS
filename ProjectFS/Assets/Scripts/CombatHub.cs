using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CombatHub : MonoBehaviour
{
    float rangeAttackTimer = 0;
    float meleeAttackTimer = 0;
    public float rangedChargeThresholdTime = 2;
    public float meleeChargeThresholdTime = 1;
    public GameObject lightProjectilePrefab;
    public GameObject chargedProjectilePrefab;
    public Transform launchTransform;
    Vector3 mousePos;
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
    public float chargedAttackKnockbackStrength = 5;
    public float chargedAttackKnockbackStrengthUp = 2;

    float attackTimer = 0;
    public float attackPauseTime;

    public Animator swordAnimator;
    public LayerMask enemyLayers;

    public Transform aimTransform;
    float aimAngle = 0;
    [SerializeField] float aimSpeed;
    [SerializeField] float aimRadius;
    [SerializeField] float aimPanStart;
    [SerializeField] float aimPanEnd;

    float aimTime;
    float aimTimer;
    float _aimPanStart;
    float _aimPanEnd;
    bool isAiming = false;

    PlayerController playerController;
    void Start()
    {
        Physics.IgnoreLayerCollision(0, 6);
        playerController = GetComponent<PlayerController>();
        
    }

    void Update()
    {
        if (!isAiming)
        {
            if (Input.GetKeyDown(KeyCode.R))
            {
                isAiming = true;
            }
            aimTransform.gameObject.SetActive(false);
        }
        else
        {
            aimTransform.gameObject.SetActive(true);
            PanAim();
            if (Input.GetKeyDown(KeyCode.R))
            {
                LaunchProjectile();
                isAiming = false;
            }
        }

        if (Input.GetMouseButton(0))
        {
            meleeAttackTimer += Time.deltaTime;
        }
        else if (Input.GetMouseButtonUp(0))
        {
            if (attackTimer > attackPauseTime)
            {
                if (meleeAttackTimer < meleeChargeThresholdTime)
                {
                    StartCoroutine(LightMeleeAttack());
                }
                else
                {
                    ChargedMeleeAttack();
                }
                meleeAttackTimer = 0;
                attackTimer = 0;
            }
        }
        attackTimer += Time.deltaTime;
    }

    IEnumerator LightMeleeAttack()
    {
        swordAnimator.SetTrigger("LightAttack");
        yield return new WaitForSeconds(0.11f);

        Collider[] enemiesHit = Physics.OverlapSphere(attackPoint.position, lightAttackRange, enemyLayers, QueryTriggerInteraction.Collide);

        foreach(Collider collider in enemiesHit)
        {
            if (collider.gameObject.GetComponent<Enemy>() != null)
            {
                Enemy enemy = collider.gameObject.GetComponent<Enemy>();

                enemy.LoseHealth(lightAttackDamage);

                enemy.Knockback(transform, lightAttackKnockbackStrength, lightAttackKnockbackStrengthUp);

            }   
        }
    }

    void ChargedMeleeAttack()
    {
        swordAnimator.SetTrigger("LightAttack");

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

        Vector3 direction = aimTransform.position - lightProjectile.transform.position;

        lightProjectile.GetComponent<Rigidbody>().velocity = direction.normalized * lightProjectile.GetComponent<LightProjectile>().speed;
        
    }

    void PanAim()
    {
        if (!playerController.IsFacingRight)
        {
            _aimPanStart = aimPanStart;
            _aimPanEnd = aimPanEnd;
        }
        else
        {
            _aimPanStart = -aimPanStart;
            _aimPanEnd = -aimPanEnd;
        }

        aimTimer += Time.deltaTime * aimSpeed;

        aimTime = Mathf.PingPong(aimTimer, 1);

        aimAngle = Mathf.Lerp(_aimPanStart, _aimPanEnd, aimTime);

        float x = Mathf.Sin(aimAngle) * aimRadius;
        float y = Mathf.Cos(aimAngle) * aimRadius;
        float z = 0;

        aimTransform.position = transform.position + new Vector3(x, y, z);
    }

    void Shield()
    {

    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.DrawWireSphere(attackPoint.position, lightAttackRange);
        Gizmos.DrawWireSphere(attackPoint.position, chargedAttackRange);
    }
}
