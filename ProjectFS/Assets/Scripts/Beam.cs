using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Beam : MonoBehaviour
{
    public Collider beamcollider;
    public MeshRenderer meshRenderer;
    public Material material;
    public Color holoColor;
    public Color activatedColor;

    private void Start()
    {
        material = meshRenderer.material;
        meshRenderer.enabled = false;
    }

    public void AimAtPlayer(Vector3 playerPosition)
    {
        meshRenderer.enabled = true;
        material.color = holoColor;

        Vector3 direction = playerPosition - transform.position;

        float angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg;

        transform.rotation = Quaternion.AngleAxis(angle, Vector3.forward);

    }

    public void Activate()
    {
        material.color = activatedColor;
        beamcollider.enabled = true;
    }

}
