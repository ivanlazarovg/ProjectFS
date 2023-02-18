using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpikeyBlock : MonoBehaviour
{
    public float knockbackStrength;
    public LayerMask playerMask;
    public LayerMask projectileMask;
    public float damage;

    private void OnCollisionEnter(Collision collision)
    {
        if((playerMask.value & (1 << collision.collider.transform.gameObject.layer)) > 0)
        {
            Knockback(collision.collider.gameObject.GetComponent<Rigidbody>());
            PlayerCombat.instance.TakeDamage(damage);
        }

        if ((projectileMask.value & (1 << collision.collider.transform.gameObject.layer)) > 0)
        {
            Destroy(collision.collider.transform.gameObject);
        }

    }

    public void Knockback(Rigidbody rb)
    {
        Vector3 direction;
        direction = rb.transform.position - transform.position;
        rb.AddForce(direction.normalized * knockbackStrength, ForceMode.Impulse);
    }

}
