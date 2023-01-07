using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightProjectile : MonoBehaviour
{
    public float speed;

    private void OnCollisionEnter(Collision collision)
    {
        Destroy(this.gameObject);
    }
}


