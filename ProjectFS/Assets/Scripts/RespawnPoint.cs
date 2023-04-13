using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RespawnPoint : MonoBehaviour
{
    private PlayerInteraction playerInteraction;

    private void Start()
    {
        playerInteraction = FindObjectOfType<PlayerInteraction>();
    }
    private void OnTriggerEnter(Collider other)
    {
        /*if (other.gameObject.GetComponent<PlayerCombat>())
        {
            playerInteraction.lastRespawnPoint = this;
        }*/
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireCube(transform.position, new Vector3(2, 2, 2));
    }
}
