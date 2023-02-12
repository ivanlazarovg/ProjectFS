using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthPickUp : MonoBehaviour
{
    public float healthamount;
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.GetComponent<PlayerCombat>())
        {
            PlayerCombat playerCombat = other.gameObject.GetComponent<PlayerCombat>();
            playerCombat.GainHealth(healthamount);
            Destroy(gameObject);
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, 1f);
    }
}
