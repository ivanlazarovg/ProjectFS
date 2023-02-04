using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwitchUnlocker : MonoBehaviour
{
    public PlatformsSwitch platformsSwitch;
    //when you have the final model do something to display on the unlocker that the switch has been activated

    private void OnTriggerStay(Collider other)
    {
        if (other.gameObject.name == "Player")
        {
            print("player");
            if (Input.GetKeyDown(KeyCode.E))
            {
                platformsSwitch.Activate();
            }
        }
    }
}
