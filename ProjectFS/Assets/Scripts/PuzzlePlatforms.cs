using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PuzzlePlatforms : MonoBehaviour
{
    public PlatformsSwitch platformsSwitch;

    private MeshRenderer meshRenderer;
    private BoxCollider boxCollider;

    public GameObject[] switchableObjects;

    private void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>(); 
        boxCollider = GetComponent<BoxCollider>();
        foreach(var item in switchableObjects)
        {
            item.transform.position = transform.position;
        }
    }

    private void Update()
    {
        if(platformsSwitch != null && platformsSwitch.isActivated)
        {
            for (int i = 0; i < switchableObjects.Length; i++)
            {
                if(i == platformsSwitch.platformSwitchMode)
                {
                    switchableObjects[i].SetActive(true);
                }
                else
                {
                    switchableObjects[i].SetActive(false);
                }
            }
        }
    }
}
