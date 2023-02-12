using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using Pathfinding;
using System.Threading;

public abstract class Enemy : MonoBehaviour
{
    public Rigidbody rb;
    public bool knockbacked;

    public Vector3 knockbackVelocity;

    [HideInInspector]
    public Animator enemyAnimator;
    public Animator playerAnimator;
    public Transform playerTransform;

    public bool isPlayerBehind;
    public bool isFacingPlayer;

    public EnemyParams enemyParams;

    public virtual void LoseHealth(float healthLost)
    {
        if (enemyAnimator != null)
        {
            enemyAnimator.SetTrigger("isHit");
        }
        enemyParams.health -= healthLost;
    }

    public void Knockback(Transform knockbackSourcePoint, float knockbackStrength, float knockBackStrengthUp)
    {
        Vector3 direction;
        direction = this.transform.position - knockbackSourcePoint.position;
        knockbacked = true;
        rb.AddForce((Vector3.up + direction.normalized * 1.3f).normalized  * knockBackStrengthUp, ForceMode.Impulse);
        knockbackVelocity = direction.normalized * knockbackStrength;
        StartCoroutine(StopKnockback());
    }

    private IEnumerator StopKnockback()
    {
        yield return new WaitForSeconds(enemyParams.knockbackRecoverySpeed);
        knockbacked = false;
    }

    public void Turn()
    {
        Vector3 rotation = transform.rotation.eulerAngles;
        rotation.y *= -1;
        transform.rotation = Quaternion.Euler(rotation);

        isFacingPlayer = !isFacingPlayer;
    }

    public void CheckDirectionToFace()
    {
        if(isPlayerBehind != isFacingPlayer)
        {
            Turn();
        }
    }

    public void isPlayerInAttackZone()
    {
        if(Physics.CheckSphere(transform.position, enemyParams.attackRange, enemyParams.playerMask))
        {
            BeginAttack();
            return;
        }
        else
        {
            return;
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, enemyParams.attackRange);
    }

    public abstract void BeginAttack();

}
