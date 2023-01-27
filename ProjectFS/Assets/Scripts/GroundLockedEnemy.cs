using Pathfinding;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GroundLockedEnemy : Enemy
{
    public float chargeSpeed;
    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Vector3.Distance(transform.position, playerTransform.position) <= distanceToAttack)
        {
            enemyAnimator.SetTrigger("isAttacking");
            enemyAnimator.SetBool("isRunning", false);

        }
        else
        {
            if (GetComponent<AIDestinationSetter>().target != null)
            {
                enemyAnimator.SetBool("isRunning", true);
            }
            else
            {
                enemyAnimator.SetBool("isRunning", false);
            }
        }

        CheckDirectionToFace();

        GetComponent<AIPath>().maxSpeed = defaultSpeed;

        if (health <= 0)
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
            knockbackVelocity.x = Mathf.Lerp(knockbackVelocity.x, 0f, Time.deltaTime * knockbackLerpTime);

            rb.velocity = new Vector3(knockbackVelocity.x, rb.velocity.y, rb.velocity.z);
        }
        else
        {
            rb.velocity = new Vector3(0, 0, 0);
        }

    }
    public override void Attack()
    {
        if (Vector3.Distance(transform.position, playerTransform.position) <= distanceToAttack)
        {
            playerAnimator.SetTrigger("hurt");
            playerAnimator.gameObject.GetComponent<PlayerCombat>().TakeDamage(attackDamage);
        }
    }

}
