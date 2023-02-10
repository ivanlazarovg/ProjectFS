using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NarrativeObjectInteractable : MonoBehaviour
{
    private Material objectMaterial;
    [HideInInspector]
    public Color highlightedColor;
    public Color defaultColor;

    public bool isHighlighted;

    public InteractionUIScriptableObject interactionUIScriptableObject;
    public Transform _UITransform;
    public Transform cameraTransform;

    public GameObject objectInspect;

    private void Start()
    {
        objectMaterial = GetComponent<MeshRenderer>().material;
        objectMaterial.color = defaultColor;
        objectInspect.SetActive(false);
    }

    private void Update()
    {
        if (isHighlighted)
        {
            objectMaterial.color = highlightedColor;
        }
        else
        {
            objectMaterial.color = defaultColor;
        }
    }

    public InteractionUIScriptableObject GetUI(out Transform UItransform)
    {
        UItransform = _UITransform;
        return interactionUIScriptableObject;
    }

    public void SetUp(Camera camera, Transform playerTransform)
    {
        camera.transform.position = cameraTransform.position;
        camera.transform.rotation = cameraTransform.rotation;
        objectInspect.SetActive(true);
        playerTransform.GetComponent<PlayerCombat>().enabled = false;
        playerTransform.GetComponent<PlayerController>().enabled = false;
        FindObjectOfType<PlayerInteraction>().enabled = false;
    }

    


}
