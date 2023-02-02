using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "Spike Data")]
public class SpikeScriptableObject : ScriptableObject
{
    public float fallThreshold;
    public Vector3 fallDirection;
    public float fallingSpeed;
    public float impactDamage;
    public LayerMask playerMask;
    public Material material;
    public Color color1;
    public Color color2;
}
