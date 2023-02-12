using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BeamImpact : MonoBehaviour
{
    private LaserEnemy laserEnemy;
    private PlayerCombat playerCombat;
    public LayerMask playerMask;

    private void Start()
    {
        laserEnemy = GetComponentInParent<LaserEnemy>();
        playerCombat = FindObjectOfType<PlayerCombat>();
    }
    private void OnTriggerEnter(Collider other)
    {
        if ((playerMask.value & (1 << other.transform.gameObject.layer)) > 0)
        {
            playerCombat.TakeDamage(laserEnemy.enemyParams.attackDamage);
        }
    }
}
