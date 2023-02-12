using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "Enemy Data")]
public class EnemyParams : ScriptableObject
{
    public float health = 5f;
    public float knockbackRecoverySpeed = 0.5f;
    public float knockbackLerpTime;
    public float distanceToAttack;
    public float attackDamage;
    public float defaultSpeed;
    public float attackRange;
    public LayerMask playerMask;
}
