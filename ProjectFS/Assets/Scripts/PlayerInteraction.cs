using JetBrains.Annotations;
using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class PlayerInteraction : MonoBehaviour
{
    public GameObject carriedObject;
    public Transform carryTransform;
    public LayerMask moveableObjectMask;
    private Collider[] moveableObjectColliders;
    [HideInInspector]
    public RespawnPoint lastRespawnPoint;
    public Transform playerTransform;
    public TextMeshProUGUI textMesh;
    public LayerMask narrativeObjectMask;
    private Collider[] narrativeObjectColliders;
    private bool isMovingObject = false;
    public Color highlightColor;

    private InteractionUIScriptableObject currentInteractionUIObject;
    private Transform interactionUItransform;
    public InteractionUI interactionUI;

    private void Start()
    {
        playerTransform = GameObject.Find("Player").transform;
    }

    private void Update()
    {
        MovingObjectsInteraction();
        NarrativeObjectInteraction();
    }

    public IEnumerator DeathCondition()
    {
        textMesh.enabled = true;
        playerTransform.GetComponent<PlayerCombat>().enabled = false;
        playerTransform.GetComponent<PlayerController>().enabled = false;
        playerTransform.GetChild(0).gameObject.SetActive(false);
        yield return new WaitUntil(() => Input.GetKeyDown(KeyCode.Space));
        Respawn();
    }

    public void Respawn()
    {
        playerTransform.position = lastRespawnPoint.transform.position;
        playerTransform.GetComponent<PlayerCombat>().enabled = true;
        playerTransform.GetComponent<PlayerCombat>().healthBarSlider.value = 100;
        playerTransform.GetComponent<PlayerController>().enabled = true;
        playerTransform.GetChild(0).gameObject.SetActive(true);
        textMesh.enabled = false;
    }

    public void MovingObjectsInteraction()
    {
        moveableObjectColliders = Physics.OverlapSphere(playerTransform.position, 1f, moveableObjectMask, QueryTriggerInteraction.Collide);

        if (moveableObjectColliders.Length != 0 && carriedObject == null)
        {
            if (moveableObjectColliders[0] != null)
            {
                if (Input.GetKeyDown(KeyCode.E))
                {
                    carriedObject = moveableObjectColliders[0].gameObject;
                    carriedObject.transform.SetParent(transform);
                    carriedObject.GetComponent<Rigidbody>().isKinematic = true;
                    carriedObject.GetComponent<BoxCollider>().enabled = false;
                    isMovingObject = true;
                }
            }

        }

        if (carriedObject != null)
        {
            carriedObject.transform.position = carryTransform.position;

            if (Input.GetKeyDown(KeyCode.Y))
            {
                carriedObject.GetComponent<BoxCollider>().enabled = true;
                carriedObject.transform.SetParent(null);
                carriedObject.GetComponent<Rigidbody>().isKinematic = false;
                carriedObject = null;
                isMovingObject = false;
            }
        }
    }

    public void NarrativeObjectInteraction()
    {
        narrativeObjectColliders = Physics.OverlapSphere(playerTransform.position, 5f, narrativeObjectMask, QueryTriggerInteraction.Collide);

        if (!isMovingObject && narrativeObjectColliders.Length > 0)
        {
            NarrativeObjectInteractable narrObject = narrativeObjectColliders[narrativeObjectColliders.Length - 1]
                .gameObject.GetComponent<NarrativeObjectInteractable>();

            narrObject.highlightedColor = highlightColor;
            narrObject.isHighlighted = true;
            currentInteractionUIObject = narrObject.GetUI(out interactionUItransform);
            interactionUI.gameObject.SetActive(true);
            interactionUI.ShowUI(currentInteractionUIObject, interactionUItransform);
            
            if (Input.GetKeyDown(KeyCode.E))
            {

            }
        }
        else
        {
            foreach(var item in FindObjectsOfType<NarrativeObjectInteractable>())
            {
                item.isHighlighted = false;
            }

            interactionUI.gameObject.SetActive(false);
        }
    }

    

}
