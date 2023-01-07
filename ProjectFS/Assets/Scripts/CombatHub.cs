using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CombatHub : MonoBehaviour
{
    float rangeAttackTimer = 0;
    public float rangedChargeThresholdTime = 2;
    public GameObject lightProjectilePrefab;
    public GameObject chargedProjectilePrefab;
    public Transform launchTransform;
    Vector3 mousePos;
    public Camera cam;
    void Start()
    {
        Physics.IgnoreLayerCollision(0, 6);
    }

    void Update()
    {
        if (Input.GetMouseButton(1))
        {
            rangeAttackTimer += Time.deltaTime;
        }
        else if (Input.GetMouseButtonUp(1))
        {
            if(rangeAttackTimer < rangedChargeThresholdTime)
            {
                LaunchLightProjectile();
            }
            else
            {
                LaunchBouncingProjectile();
            }
            rangeAttackTimer = 0;
        }
    }

    void LightMeleeAttack()
    {

    }

    void ChargedMeleeAttack()
    {

    }

    void LaunchLightProjectile()
    {
        GameObject lightProjectile = Instantiate(lightProjectilePrefab, launchTransform.position, Quaternion.identity);

        mousePos = new Vector3(cam.ScreenToWorldPoint(Input.mousePosition).x, cam.ScreenToWorldPoint(Input.mousePosition).y, -4.74f);

        Vector3 direction = mousePos - lightProjectile.transform.position;

        lightProjectile.GetComponent<Rigidbody>().velocity = direction.normalized * lightProjectile.GetComponent<LightProjectile>().speed;
        
    }

    void LaunchBouncingProjectile()
    {
        GameObject chargedProjectile = Instantiate(chargedProjectilePrefab, launchTransform.position, Quaternion.identity);

        mousePos = new Vector3(cam.ScreenToWorldPoint(Input.mousePosition).x, cam.ScreenToWorldPoint(Input.mousePosition).y, -4.74f);

        Vector3 direction = mousePos - chargedProjectile.transform.position;

        chargedProjectile.GetComponent<Rigidbody>().velocity = direction.normalized * chargedProjectile.GetComponent<ChargedProjectile>().speed;
    }

    void Shield()
    {

    }
}
