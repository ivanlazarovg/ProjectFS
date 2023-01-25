using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using Pathfinding;

public class Enemy : MonoBehaviour
{
    public float health = 5f;
    private Rigidbody rb;
    public bool knockbacked;
    [SerializeField] float knockbackRecoverySpeed = 0.5f;
    [SerializeField] float knockbackLerpTime;


    Vector3 direction;
    float _knockbackStrength;
    Vector3 knockbackVelocity;

    public Animator enemyAnimator;
    public Transform playerTransform;

    private bool isPlayerBehind;
    private bool isFacingPlayer;

    private void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    private void Update()
    {
        CheckDirectionToFace();

        print(rb.velocity.x);
        if(GetComponent<AIDestinationSetter>().target != null)
        {
            enemyAnimator.SetBool("isRunning",true);
        }
        else
        {
            enemyAnimator.SetBool("isRunning", false);
        }

        if (health <= 0)
        {
            Destroy(gameObject);
        }

        if(playerTransform.position.x > transform.position.x)
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
}
