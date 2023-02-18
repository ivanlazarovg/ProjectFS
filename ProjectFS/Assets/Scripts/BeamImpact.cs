using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BeamImpact : MonoBehaviour
{
    private LaserEnemy laserEnemy;
    public LayerMask playerMask;

    private void Start()
    {
        laserEnemy = GetComponentInParent<LaserEnemy>();
    }
    private void OnTriggerEnter(Collider other)
    {
        if ((playerMask.value & (1 << other.transform.gameObject.layer)) > 0)
        {
            PlayerCombat.instance.TakeDamage(laserEnemy.enemyParams.attackDamage);
        }
    }
}
