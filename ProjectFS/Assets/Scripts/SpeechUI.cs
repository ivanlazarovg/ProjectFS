using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class SpeechUI : MonoBehaviour
{
    public Speaker speaker;
    public TMP_Text textUI;
    public float typeSpeed;
    public Sprite speakerProfile;
    public Image profileImage;

    private void LateUpdate()
    {
        if (textUI.gameObject.activeSelf)
        {
            profileImage.sprite = speakerProfile;
        }
    }

}
