using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FallingSpike : MonoBehaviour
{
    public bool isActivated;
    private float timer = 0;
    private float colorLerptimer = 0;
    private bool isFalling = false;
    private PlayerCombat playerCombat;

    public SpikeScriptableObject spikeParams;
    private Material _spikeMaterial;

    private void Start()
    {
        _spikeMaterial = spikeParams.material;
        playerCombat = FindObjectOfType<PlayerCombat>();
    }

    void FixedUpdate()
    {
        if (isActivated)
        {
            timer += Time.deltaTime;
            colorLerptimer += Time.deltaTime / spikeParams.fallThreshold;

            _spikeMaterial.SetColor("_Color", Color.Lerp(spikeParams.color1, spikeParams.color2, colorLerptimer));
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
            playerCombat.TakeDamage(spikeParams.impactDamage);
        }
    }
}
