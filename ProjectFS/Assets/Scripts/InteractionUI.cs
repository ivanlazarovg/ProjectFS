using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class InteractionUI : MonoBehaviour
{
    public TextMeshProUGUI textMesh;

    public void ShowUI(InteractionUIScriptableObject interactionUIparams, Transform interactionUItransform)
    {
        textMesh.text = interactionUIparams.text;
        transform.position = interactionUItransform.position;
    }
}
