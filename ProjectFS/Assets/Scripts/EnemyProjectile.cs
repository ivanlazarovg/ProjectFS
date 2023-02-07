using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyProjectile : MonoBehaviour
{
    public float speed;
    public float gravity;
    Rigidbody rb;
    private float collisionCounter;
    public float collisionCounterLimit;
    public PhysicMaterial material;
    public float damage;

    private void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    private void Update()
    {
        rb.velocity = new Vector3(rb.velocity.x, rb.velocity.y - gravity, rb.velocity.z);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.collider.gameObject.GetComponent<PlayerCombat>() != null)
        {
            collision.collider.gameObject.GetComponent<PlayerCombat>().TakeDamage(damage);
        }
        Destroy(this.gameObject);
    }
}
