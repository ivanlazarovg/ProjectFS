using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ButtonPress : MonoBehaviour
{
    public GameObject door;

    private void OnCollisionEnter(Collision collision)
    {
        if(collision.collider.gameObject.tag == "collidable")
        {
            door.SetActive(false);
        }
    }

    private void OnCollisionExit(Collision collision)
    {
        if (collision.collider.gameObject.tag == "collidable")
        {
            door.SetActive(true);
        }
    }
}
