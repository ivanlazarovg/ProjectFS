using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Pathfinding;

public class RangedFlyingEnemy : Enemy
{
    public AIPath path;
    public Transform launchTransform;
    public GameObject projectilePrefab;
    public AIDestinationSetter destinationSetter;
    public float attackInterval;
    private bool canAttack = true;
    public float projectileDamage;
    public float projectileSpeed;
    void Start()
    {
        rb = GetComponent<Rigidbody>();
        rb.useGravity = false;
        enemyAnimator = GetComponent<Animator>();
    }
    
    void Update()
    {
        if (path.velocity == Vector3.zero && canAttack)
        {
            Attack();
        }

        CheckDirectionToFace();

        GetComponent<AIPath>().maxSpeed = defaultSpeed;

        if (health <= 0)
        {
            Destroy(gameObject);
        }
    }

    public void Attack()
    {
        canAttack = false;
        StartCoroutine(LaunchProjectile());
    }

    private IEnumerator LaunchProjectile()
    {
        GameObject projectile = Instantiate(projectilePrefab, launchTransform.position, Quaternion.identity);
        SetProjectileValues(projectile);

        Vector3 direction = destinationSetter.target.transform.position - projectile.transform.position;

        projectile.GetComponent<Rigidbody>().velocity = direction.normalized * projectile.GetComponent<EnemyProjectile>().speed;

        yield return new WaitForSeconds(attackInterval);

        canAttack = true;
    }

    private void SetProjectileValues(GameObject projectile)
    {
        projectile.GetComponent<EnemyProjectile>().damage = projectileDamage;
        projectile.GetComponent<EnemyProjectile>().speed = projectileSpeed;
    }
}
