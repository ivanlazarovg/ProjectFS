using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Scene Act", menuName = "ScriptableObjects/Scene Act", order = 3)]
public class SceneAct : ScriptableObject
{
    public SpeechObject[] speechObjects;
}
