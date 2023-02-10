using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NarrativeObjectEngage : MonoBehaviour
{
    public SpeechObject[] spiritSpeeches;
    public NarrativeObjectInteractable narrativeObject;
    private Transform playerTransform;
    private PlayerInteraction playerInteraction;
    public float turnSpeed;

    private void Start()
    {
        playerTransform = GameObject.Find("Player").transform;
        playerInteraction = FindObjectOfType<PlayerInteraction>();
    }

    private void Update()
    {
        isBeingObserved();
    }

    public void isBeingObserved()
    {
        Turn();

        if (Input.GetKeyDown(KeyCode.Escape))
        {
            playerInteraction.DisengageInspect(playerTransform, this.gameObject);
        }
    }

    public void Turn()
    {
        if (Input.GetMouseButton(0))
        {
            float rotX = Input.GetAxis("Mouse X") * turnSpeed * Mathf.Deg2Rad;
            float rotY = Input.GetAxis("Mouse Y") * turnSpeed * Mathf.Deg2Rad;

            transform.Rotate(Vector3.up, -rotX);
            transform.Rotate(Vector3.right, rotY);
        }

    }
}
