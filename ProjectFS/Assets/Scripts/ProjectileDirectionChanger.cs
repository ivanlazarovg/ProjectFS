using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class ProjectileDirectionChanger : MonoBehaviour
{
    public Vector3 direction;
    public float speedBoost;
    public bool speedMultiplier;
    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.GetComponent<LightProjectile>() != null)
        {
            Rigidbody rb = other.gameObject.GetComponent<Rigidbody>();
            rb.velocity = speedMultiplier ? direction.normalized * (rb.gameObject.GetComponent<LightProjectile>().speed * speedBoost)
                : direction.normalized * rb.gameObject.GetComponent<LightProjectile>().speed;
        }
    }
}
