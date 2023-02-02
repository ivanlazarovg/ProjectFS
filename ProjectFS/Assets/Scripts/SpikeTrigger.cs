using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpikeTrigger : MonoBehaviour
{
    [SerializeField]
    private FallingSpike spike;
    [SerializeField]
    private LayerMask playerMask;

    private void OnTriggerEnter(Collider other)
    {
        if((playerMask.value & (1 << other.transform.gameObject.layer)) > 0)
        {
            spike.isActivated = true;
        }
    }
}
