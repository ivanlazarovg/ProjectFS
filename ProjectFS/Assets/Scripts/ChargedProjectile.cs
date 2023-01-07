using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChargedProjectile : MonoBehaviour
{
    public float speed;
    private float collisionCounter;
    public float collisionCounterLimit;

    public PhysicMaterial material;
    private void Update()
    {
        material.bounceCombine = PhysicMaterialCombine.Maximum;
    }

    private void OnCollisionEnter(Collision collision)
    {
        collisionCounter++;
        if (collisionCounter > collisionCounterLimit)
        {
            Destroy(this.gameObject);
        }
    }
}
