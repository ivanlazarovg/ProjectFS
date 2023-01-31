using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;


[CreateAssetMenu(fileName = "Speech", menuName = "ScriptableObjects/Speech", order = 1)]
public class SpeechObject : ScriptableObject
{
    public TextAsset speech;
    public ResponseObject[] responses;
    public SpeechObject nextSpeech;

    public bool hasResponseAttached;
    public bool hasSpeechAttached;
    public bool hasAnimation;
    public bool makeFly;
}
