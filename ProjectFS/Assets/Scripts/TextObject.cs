using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class TextObject : MonoBehaviour
{
    public InteractionUIScriptableObject interactionUIObject;
    public TextMeshProUGUI textMesh;

    public void Start()
    {
        textMesh = GetComponentInParent<TextMeshProUGUI>();
        textMesh.text = interactionUIObject.text;
    }
}
