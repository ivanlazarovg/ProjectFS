using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FallingSpike : MonoBehaviour
{
    public bool isActivated;
    private float timer = 0;
    private float colorLerptimer = 0;
    private bool isFalling = false;

    public SpikeScriptableObject spikeParams;
    private MaterialPropertyBlock propertyBlock;
    private Renderer meshRenderer;

    private void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        propertyBlock = new MaterialPropertyBlock();
        SetPropertyBlockColor(spikeParams.color1);
    }

    void FixedUpdate()
    {
        if (isActivated)
        {
            timer += Time.deltaTime;
            
            SetPropertyBlockColor(Color.Lerp(spikeParams.color1, spikeParams.color2, timer/spikeParams.fallThreshold));
        }
        if (timer >= spikeParams.fallThreshold)
        {
            isActivated = false;
            timer = 0;
            isFalling = true;
        }

        if (isFalling)
        {
            Fall();
        }
    }

    public void Fall()
    {
        transform.position += spikeParams.fallDirection.normalized * spikeParams.fallingSpeed;
    }

    private void OnTriggerEnter(Collider collider)
    {
        if ((spikeParams.playerMask.value & (1 << collider.transform.gameObject.layer)) > 0)
        {
            PlayerCombat.instance.TakeDamage(spikeParams.impactDamage);
        }
    }

    public void SetPropertyBlockColor(Color color)
    {
        meshRenderer.GetPropertyBlock(propertyBlock);

        propertyBlock.SetColor("_Color", color);

        meshRenderer.SetPropertyBlock(propertyBlock);
    }
}
