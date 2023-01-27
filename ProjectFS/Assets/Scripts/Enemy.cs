using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using Pathfinding;
using System.Threading;

public abstract class Enemy : MonoBehaviour
{
    public float health = 5f;
    public Rigidbody rb;
    public bool knockbacked;
    public float knockbackRecoverySpeed = 0.5f;
    public float knockbackLerpTime;


    Vector3 direction;
    public float _knockbackStrength;
    public Vector3 knockbackVelocity;

    public Animator enemyAnimator;
    public Animator playerAnimator;
    public Transform playerTransform;

    public bool isPlayerBehind;
    public bool isFacingPlayer;

    public float distanceToAttack;

    public float attackDamage;

    public float defaultSpeed;


    public void LoseHealth(float healthLost)
    {
        enemyAnimator.SetTrigger("isHit");
        health -= healthLost;
    }

    public void Knockback(Transform knockbackSourcePoint, float knockbackStrength, float knockBackStrengthUp)
    {
        direction = this.transform.position - knockbackSourcePoint.position;
        knockbacked = true;
        rb.AddForce((Vector3.up + direction.normalized * 1.3f).normalized  * knockBackStrengthUp, ForceMode.Impulse);
        knockbackVelocity = direction.normalized * knockbackStrength;
        StartCoroutine(StopKnockback());
    }

    private IEnumerator StopKnockback()
    {
        yield return new WaitForSeconds(knockbackRecoverySpeed);
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

    public abstract void Attack();

}
