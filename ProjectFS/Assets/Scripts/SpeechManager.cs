using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Linq;
using UnityEngine.Playables;

public class SpeechManager : MonoBehaviour
{
    //private char[] intonationCharacters = new char[] { '|', '/', '[', '-', '=', '+', '(', ')', '{', '[', '}', '`',};
    //public Dictionary<char, float> intonationCharsDictionary = new Dictionary<char, float>();
    public CharWaitTimePair[] charWaitTimePair;
    Speaker speaker;
    GameObject _speakerObject;
    TMP_Text _textUI;
    public bool isTalking;
    SpeechUI speechUI;
    public float scrollDown;
    bool isResponding;
    [SerializeField]
    private RectTransform speechRect;

    public ResponseHandler responseHandler;

    [SerializeField] float scrollValue;
    public SceneTrigger tempTrigger;

    private void Start()
    {   
        speechUI = GetComponent<SpeechUI>();
    }

    public void Run(SpeechObject speech, TMP_Text textUI, float typeSpeed, GameObject speakerObject)
    {
        speaker = speakerObject.GetComponent<Speaker>();
        speechUI.speakerProfile = speaker.speakerProfile;
        speech.hasResponseAttached = speech.responses.Length != 0 ? true : false;
        speech.hasSpeechAttached = speech.nextSpeech != null ? true : false;
        
        responseHandler.pickedResponse = null;
        responseHandler.responses = null;

        StartCoroutine(PresentText(speech, textUI, typeSpeed, speakerObject));

    }

    public IEnumerator PresentText(SpeechObject speech, TMP_Text textUI, float typeSpeedOrigin, GameObject speakerObject)
    {
        string text = speech.speech.ToString();
        speechUI.textUI.gameObject.transform.parent.transform.parent.gameObject.transform.parent.gameObject.SetActive(true);
        textUI.rectTransform.position = speechRect.position;
        _textUI = textUI;
        _speakerObject = speakerObject;

        speaker.canTalkTo = false;
        float time = 0;
        int charIndex = 0;
        float typeSpeed = typeSpeedOrigin;
        string tempText = string.Empty;

        isTalking = true;

        while (charIndex < text.Length)
        {    
            typeSpeed = typeSpeedOrigin;

            if (CheckChar(text[charIndex], out float waitSpeed))
            {
                yield return new WaitForSeconds(waitSpeed);
            }
            else if (text[charIndex] == ' ')
            {
                typeSpeed = typeSpeedOrigin * 2;
            }
            
            time += Time.deltaTime * typeSpeed;
            charIndex = Mathf.FloorToInt(time);
            charIndex = Mathf.Clamp(charIndex, 0, text.Length);

            string tempSubString = text.Substring(0, charIndex);
            tempText = ReplaceAndCountChars(tempSubString, text, out int frequency);

            textUI.text = tempText.Substring(0, charIndex - frequency);
            //speechUI.textUI.rectTransform.position -= new Vector3(0, scrollValue, 0);

            yield return null;
        }
        textUI.text = tempText;
        

        if (speech.hasResponseAttached)
        {
            yield return new WaitForSeconds(0.5f);
            responseHandler.isResponding = true;
            responseHandler.ShowResponses(speech.responses);
            Cursor.visible = true;
            yield return new WaitUntil(() => responseHandler.isResponding == false);
            if (responseHandler.pickedResponse.speechObject == null)
            {
                Cursor.visible = false;
                ExitSpeech(speakerObject, speaker, _textUI, speech);
            }
            else
            {
                Cursor.visible = false;
                Run(responseHandler.pickedResponse.speechObject, speechUI.textUI, speechUI.typeSpeed, speakerObject);
            }
        }
        else if(speech.hasSpeechAttached)
        {
            yield return new WaitUntil(() => Input.GetMouseButtonDown(0));
            Run(speech.nextSpeech, speechUI.textUI, speechUI.typeSpeed, speakerObject);
        }
        else
        {
            yield return new WaitUntil(() => Input.GetMouseButtonDown(0));
            ExitSpeech(_speakerObject, speaker, _textUI, speech);

        }

    }

    private void Update()
    {
        if (isTalking)
        {
            Cursor.visible = false;
            Cursor.lockState = CursorLockMode.None;
        }
        else
        {
            Cursor.visible = false;
            Cursor.lockState = CursorLockMode.Locked;
        }
        
    }

    private bool CheckChar(char charAtIndex, out float waitTime)
    {
        foreach(var item in charWaitTimePair)
        {
            if(item.intonationCharacter == charAtIndex)
            {
                waitTime = item.characterWaitTime;
                return true;
            }
        }
        waitTime = default;
        return false;
    }

    public string ReplaceAndCountChars(string tempSubString, string text, out int frequency)
    {
        frequency = 0;
        foreach (var item in charWaitTimePair)
        {
            frequency += tempSubString.Count(f => (f == item.intonationCharacter));
            text = text.Replace(item.intonationCharacter.ToString(), "");
        }
        return text;
    }

    private void ExitSpeech(GameObject speakerObject, Speaker speaker, TMP_Text textUI, SpeechObject speech)
    {
        speaker.canTalkTo = true;
        textUI.text = "";
        textUI.transform.parent.transform.parent.transform.parent.gameObject.SetActive(false);
        isTalking = false;
        speaker.isTalking = false;
        responseHandler.pickedResponse = null;
        
    }
    
}

[System.Serializable]
public class CharWaitTimePair
{
    public char intonationCharacter;
    public float characterWaitTime;
}

