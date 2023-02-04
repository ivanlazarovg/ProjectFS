using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FallingPlatform : MonoBehaviour
{
    private float timer = 0;
    private bool isTicking;

    public FallingPlatformParams fallingPlatformParams;
    private Renderer meshRenderer;
    private MaterialPropertyBlock propertyBlock;

    private void Start()
    {
        meshRenderer = GetComponent<Renderer>();
        propertyBlock = new MaterialPropertyBlock();
        SetPropertyBlockColor(fallingPlatformParams.stableColor);
    }

    private void Update()
    {
        if (isTicking)
        {
            timer += Time.deltaTime;

            SetPropertyBlockColor(ColorLerp(fallingPlatformParams.stableColor, fallingPlatformParams.fallingColor));

            if(timer >= fallingPlatformParams.fallThreshold)
            {
                isTicking = false;
            }
        }
    }

    public IEnumerator Fall()
    {
        isTicking = true;

        yield return new WaitForSeconds(fallingPlatformParams.fallThreshold);

        Destroy(gameObject);
    }

    private void SetPropertyBlockColor(Color color)
    {
        meshRenderer.GetPropertyBlock(propertyBlock);

        propertyBlock.SetColor("_Color", color);

        meshRenderer.SetPropertyBlock(propertyBlock);
    }

    private Color ColorLerp(Color color1, Color color2)
    {
        return Color.Lerp(color1, color2, timer / fallingPlatformParams.fallThreshold);
    }
}
