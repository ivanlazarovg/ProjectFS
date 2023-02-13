using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletProjectile : MonoBehaviour
{
    private Vector3 moveDirection;
    public float moveSpeed;
    public float damage;

    private void OnEnable()
    {
        Invoke("Destroy", 3f);
    }

    private void Start()
    {
        //moveSpeed = 8;
    }

    private void Update()
    {
        transform.Translate(moveDirection * moveSpeed * Time.deltaTime);
    }

    public void SetMoveDirection(Vector3 dir)
    {
        moveDirection = dir;
    }

    private void Destroy()
    {
        gameObject.SetActive(false);
    }

    private void OnDisable()
    {
        CancelInvoke();
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.GetComponent<PlayerCombat>() != null)
        {
            other.gameObject.GetComponent<PlayerCombat>().TakeDamage(damage);
            Destroy();
        }
    }
}
