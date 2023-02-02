using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlatformsSwitch : MonoBehaviour
{
    public int platformSwitchMode = 0;

    public void Switch()
    {
        if(platformSwitchMode == 0)
        {
            platformSwitchMode = 1;
        }
        else if(platformSwitchMode == 1)
        {
            platformSwitchMode = 0;
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.collider.gameObject.tag == "projectile")
        {
            Destroy(collision.collider.gameObject);
            Switch();
        }
    }
}
