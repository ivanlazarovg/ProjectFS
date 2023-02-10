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
    private void Start()
    {
        objectMaterial = GetComponent<MeshRenderer>().material;
        objectMaterial.color = defaultColor;
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
}
