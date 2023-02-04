using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlatformsSwitch : MonoBehaviour
{
    public bool isActivated = true;
    public int platformSwitchMode = 0;
    private Material _switchMaterial;

    public PlatformSwitchParams platformSwitchParams;
    private Renderer meshRenderer;
    private MaterialPropertyBlock propertyBlock;

    private void Start()
    {
        meshRenderer = GetComponent<Renderer>();
        propertyBlock = new MaterialPropertyBlock();
    }

    private void Update()
    {
        if (!isActivated)
        {
            SetPropertyBlockColor(platformSwitchParams.unactivatedColor);
        }
        else
        {
            if(platformSwitchMode == 0)
            {
                SetPropertyBlockColor(platformSwitchParams.switchColor1);
            }
            else if(platformSwitchMode == 1)
            {
                SetPropertyBlockColor(platformSwitchParams.switchColor2);
            }
        }
    }

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
        if (isActivated)
        {
            if (collision.collider.gameObject.tag == "projectile")
            {
                Destroy(collision.collider.gameObject);
                Switch();
            }
        }
    }

    public void Activate()
    {
        isActivated = true;
        _switchMaterial.SetColor("_Color", platformSwitchParams.switchColor1);
    }

    public void SetPropertyBlockColor(Color color)
    {
        meshRenderer.GetPropertyBlock(propertyBlock);

        propertyBlock.SetColor("_Color", color);

        meshRenderer.SetPropertyBlock(propertyBlock);
    }
}
