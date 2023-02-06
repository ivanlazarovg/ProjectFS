using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Platform : MonoBehaviour
{
    public Transform playerGroundChecker;
    private BoxCollider collider;

    private void Start()
    {
        collider = GetComponent<BoxCollider>();
        playerGroundChecker = GameObject.Find("GroundCheckPoint").transform;
    }

    private void FixedUpdate()
    {
        if(playerGroundChecker.position.y >= transform.position.y - 0.05f)
        {
            collider.isTrigger = false;
        }
        else
        {
            collider.isTrigger = true;
        }
    }
}
