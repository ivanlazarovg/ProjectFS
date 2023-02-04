using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Falling Platform Params", menuName = "ScriptableObjects/FallingPlatformParams", order = 3)]
public class FallingPlatformParams : ScriptableObject
{
    public Color stableColor;
    public Color fallingColor;
    public float fallThreshold;
}
