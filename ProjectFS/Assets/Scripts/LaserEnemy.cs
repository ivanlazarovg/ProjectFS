using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserEnemy : Enemy
{
    bool isInCycle = false;
     
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (!isInCycle)
        {
            StartCoroutine(castHologramShot());
        }
    }

    public IEnumerator castHologramShot()
    {
        yield return new WaitForSeconds(3f);

        StartCoroutine(Attack());
    }

    public IEnumerator Attack()
    {
        yield return new WaitForSeconds(3f);

    }
}
