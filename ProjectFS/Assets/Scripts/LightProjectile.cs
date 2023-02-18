using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightProjectile : MonoBehaviour
{
    public float speed;
    public float gravity;
    Rigidbody rb;
    private float collisionCounter;
    public float collisionCounterLimit;
    public PhysicMaterial material;

    private void Start()
    {
        rb = GetComponent<Rigidbody>();
        material.bounceCombine = PhysicMaterialCombine.Maximum;
    }

    private void Update()
    {
        rb.velocity = new Vector3(rb.velocity.x, rb.velocity.y - gravity, rb.velocity.z);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if(collision.gameObject.GetComponent<Enemy>() != null)
        {
            collision.gameObject.GetComponent<Enemy>().LoseHealth(PlayerCombat.instance.rangedDamage);
            Destroy(this.gameObject);
        }
        collisionCounter++;
        if (collisionCounter > collisionCounterLimit)
        {
            Destroy(this.gameObject);
        }
    }
}


