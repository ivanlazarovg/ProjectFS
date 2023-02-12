using Pathfinding;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GroundLockedEnemy : Enemy
{
    public float chargeSpeed;
    private AIDestinationSetter destinationSetter;
    void Start()
    {
        destinationSetter = GetComponent<AIDestinationSetter>();
        rb = GetComponent<Rigidbody>();
        enemyAnimator = GetComponent<Animator>();
    }

    void Update()
    {
        isPlayerInAttackZone();

        if (Vector3.Distance(transform.position, playerTransform.position) <= enemyParams.distanceToAttack)
        {
            enemyAnimator.SetTrigger("isAttacking");
            enemyAnimator.SetBool("isRunning", false);

        }
        else
        {
            if (destinationSetter.target != null)
            {
                enemyAnimator.SetBool("isRunning", true);
            }
            else
            {
                enemyAnimator.SetBool("isRunning", false);
            }
        }

        CheckDirectionToFace();

        GetComponent<AIPath>().maxSpeed = enemyParams.defaultSpeed;

        if (enemyParams.health <= 0)
        {
            Destroy(gameObject);
        }

        if (playerTransform.position.x > transform.position.x)
        {
            isPlayerBehind = true;
        }
        else
        {
            isPlayerBehind = false;
        }

        if (knockbacked)
        {
            knockbackVelocity.x = Mathf.Lerp(knockbackVelocity.x, 0f, Time.deltaTime * enemyParams.knockbackLerpTime);

            rb.velocity = new Vector3(knockbackVelocity.x, rb.velocity.y, rb.velocity.z);
        }
        else
        {
            rb.velocity = new Vector3(0, 0, 0);
        }

    }
    public void Attack()
    {
        if (Vector3.Distance(transform.position, playerTransform.position) <= enemyParams.distanceToAttack)
        {
            playerAnimator.SetTrigger("hurt");
            playerAnimator.gameObject.GetComponent<PlayerCombat>().TakeDamage(enemyParams.attackDamage);
        }
    }

    public override void BeginAttack()
    {
        destinationSetter.target = playerTransform;
    }

}
