using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TeleportPoint : MonoBehaviour
{
    private GameObject player;

    private void Start()
    {
        player = GameObject.Find("Player");
    }
    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "projectile")
        {
            player.transform.position = this.transform.GetChild(0).transform.position;
        }
    }
}
