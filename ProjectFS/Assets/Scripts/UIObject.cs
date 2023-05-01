using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIObject : MonoBehaviour
{
    public InteractionUIScriptableObject interactionUIScriptableObject;
    public Transform _UITransform;
    public InteractionUIScriptableObject GetUI(out Transform UItransform)
    {
        UItransform = _UITransform;
        return interactionUIScriptableObject;
    }
}
