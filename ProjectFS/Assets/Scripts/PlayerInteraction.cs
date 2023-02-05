using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInteraction : MonoBehaviour
{
    public GameObject carriedObject;
    public Transform carryTransform;
    public LayerMask moveableObjectMask;
    private Collider[] moveableObjectColliders;

    private void Update()
    {
        moveableObjectColliders = Physics.OverlapSphere(transform.position, 1f, moveableObjectMask, QueryTriggerInteraction.Collide);
        
        if (moveableObjectColliders[0] != null && carriedObject == null)
        {
            if (Input.GetKeyDown(KeyCode.E))
            {
                carriedObject = moveableObjectColliders[0].gameObject;
                carriedObject.transform.SetParent(transform);
                carriedObject.GetComponent<Rigidbody>().isKinematic = true;
            }
        }

        if (carriedObject != null)
        {
            carriedObject.transform.position = carryTransform.position;

            if (Input.GetKeyDown(KeyCode.Y))
            {
                carriedObject.transform.SetParent(null);
                carriedObject.GetComponent<Rigidbody>().isKinematic = false;
                carriedObject = null;
            }

        }
    }


}
