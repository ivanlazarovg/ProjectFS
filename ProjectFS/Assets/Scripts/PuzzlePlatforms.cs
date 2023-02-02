using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PuzzlePlatforms : MonoBehaviour
{
    public int switchNumber;
    public PlatformsSwitch platformsSwitch;

    private MeshRenderer meshRenderer;
    private BoxCollider boxCollider;

    private void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>(); 
        boxCollider = GetComponent<BoxCollider>();
    }

    private void Update()
    {
        if(platformsSwitch != null)
        {
            if (platformsSwitch.platformSwitchMode == switchNumber)
            {
                meshRenderer.enabled = true;
                boxCollider.enabled = true;
            }
            else
            {
                meshRenderer.enabled = false;
                boxCollider.enabled = false;
            }
        }
    }
}
