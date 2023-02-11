using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Pathfinding;

public class LaserEnemy : Enemy
{
    bool isInCycle = false;
    public Beam beam;
    [SerializeField]
    private float timeToHologram;
    [SerializeField]
    private float timeToActivate;
     
    void Start()
    {
        beam = GetComponentInChildren<Beam>();
    }

    void Update()
    {
        if (!isInCycle)
        {
            StartCoroutine(castHologramShot());
            beam.beamcollider.enabled = false;
            beam.meshRenderer.enabled = false;
        }

        if (health <= 0)
        {
            Destroy(gameObject);
        }
    }

    public IEnumerator castHologramShot()
    {
        isInCycle = true;
        yield return new WaitForSeconds(timeToHologram);
        beam.AimAtPlayer(playerTransform.position);

        StartCoroutine(Attack());
    }

    public IEnumerator Attack()
    {
        yield return new WaitForSeconds(timeToActivate);
        beam.Activate();

        StartCoroutine(WaitForCycle());

    }
    
    public IEnumerator WaitForCycle()
    {
        yield return new WaitForSeconds(1f);
        isInCycle = false;
    }
}
