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

    public Animator swordAnimator;
    public LayerMask enemyLayers;
    void Start()
    {
        Physics.IgnoreLayerCollision(0, 6);
        
    }

    void Update()
    {
        if (Input.GetMouseButton(1))
        {
            rangeAttackTimer += Time.deltaTime;
        }
        else if (Input.GetMouseButtonUp(1))
        {
            if(rangeAttackTimer < rangedChargeThresholdTime)
            {
                LaunchLightProjectile();
            }
            else
            {
                LaunchBouncingProjectile();
            }
            rangeAttackTimer = 0;
        }

        if (Input.GetMouseButton(0))
        {
            meleeAttackTimer += Time.deltaTime;
        }
        else if (Input.GetMouseButtonUp(0))
        {
            if (meleeAttackTimer < meleeChargeThresholdTime)
            {
                LightMeleeAttack();
            }
            else
            {
                ChargedMeleeAttack();
            }
            meleeAttackTimer = 0;
        }
    }

    void LightMeleeAttack()
    {
        swordAnimator.SetTrigger("LightAttack");

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

    void LaunchLightProjectile()
    {
        GameObject lightProjectile = Instantiate(lightProjectilePrefab, launchTransform.position, Quaternion.identity);

        Vector3 mousePosInput = Input.mousePosition;
        mousePosInput.z = 20;
        mousePos = new Vector3(cam.ScreenToWorldPoint(mousePosInput).x, cam.ScreenToWorldPoint(mousePosInput).y, -4.74f);

        Vector3 direction = mousePos - lightProjectile.transform.position;

        lightProjectile.GetComponent<Rigidbody>().velocity = direction.normalized * lightProjectile.GetComponent<LightProjectile>().speed;
        
    }

    void LaunchBouncingProjectile()
    {
        GameObject chargedProjectile = Instantiate(chargedProjectilePrefab, launchTransform.position, Quaternion.identity);

        Vector3 mousePosInput = Input.mousePosition;
        mousePosInput.z = 20;
        mousePos = new Vector3(cam.ScreenToWorldPoint(mousePosInput).x, cam.ScreenToWorldPoint(mousePosInput).y, -4.74f);

        Vector3 direction = mousePos - chargedProjectile.transform.position;

        chargedProjectile.GetComponent<Rigidbody>().velocity = direction.normalized * chargedProjectile.GetComponent<ChargedProjectile>().speed;
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
