using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class Speaker : MonoBehaviour
{
    public SpeechObject[] speeches;
    public bool canTalkTo;
    public bool isTalking;
    public Sprite speakerProfile;
    public SpeechUI speechUI;
    public SpeechManager speechManager;

  public void Talk()
    {

        if (canTalkTo)
        {
            speechManager.Run(speeches[0], speechUI.textUI, speechUI.typeSpeed, this.gameObject);

        }
    }
}
