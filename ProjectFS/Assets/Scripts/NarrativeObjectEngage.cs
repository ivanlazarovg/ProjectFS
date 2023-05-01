using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class NarrativeObjectEngage : MonoBehaviour
{
    public NarrativeObjectInteractable narrativeObject;
    private Transform playerTransform;
    public float turnSpeed;
    [SerializeField]
    private Camera cam;
    [SerializeField]
    private float speechDelay;

    [SerializeField]
    private LayerMask textMask;

    public TextMeshProUGUI readableText;

    private bool hitOnce = false;
    private bool hasTextToRead;

    private Speaker spiritSpeaker;

    public SpeechObject spiritSpeech;

    private SpeechManager speechManager;

    private SpeechUI speechUI;

    private bool hasRead;
    

    private void Start()
    {
        speechUI = FindObjectOfType<SpeechUI>();
        speechManager = FindObjectOfType<SpeechManager>();
        spiritSpeaker = GameObject.Find("Leeval").GetComponent<Speaker>();
        readableText = GameObject.Find("TextToRead").GetComponent<TextMeshProUGUI>();
        playerTransform = GameObject.Find("Player").transform;
        if(GetComponentInChildren<TextObject>() != null )
        {
            hasTextToRead = true;
        }
        else
        {
            hasTextToRead = false;
        }
    }

    private void Update()
    {
        isBeingObserved();
    }

    public void isBeingObserved()
    {
        Turn();

        if(spiritSpeech != null && !speechManager.isTalking && !hasRead)
        {
            speechManager.Run(spiritSpeech, speechUI.textUI, speechUI.typeSpeed, spiritSpeaker, speechDelay);
            hasRead = true;
        }

        if (hasTextToRead && !speechManager.isTalking)
        {
            RaycastHit hit;
            if (Physics.Raycast(cam.transform.position, cam.transform.forward, out hit, 10f, textMask))
            {
                if (!hitOnce)
                {
                    readableText.text = "press 'E' to read";
                    hitOnce = true;
                }
                if (Input.GetKeyDown(KeyCode.E))
                {
                    readableText.text = hit.collider.gameObject.GetComponent<TextObject>().interactionUIObject.text;
                }

            }
            else
            {
                hitOnce = false;
                readableText.text = string.Empty;
            }

        }


        if (Input.GetKeyDown(KeyCode.Escape))
        {
            readableText.text = string.Empty;
            PlayerInteraction.instance.DisengageInspect();
            this.gameObject.SetActive(false);
        }
    }

    public void Turn()
    {
        if (Input.GetMouseButton(0))
        {
            float rotX = Input.GetAxis("Mouse X") * turnSpeed * Mathf.Deg2Rad;
            float rotY = Input.GetAxis("Mouse Y") * turnSpeed * Mathf.Deg2Rad;

            transform.Rotate(Vector3.up, -rotX);
            transform.Rotate(Vector3.right, rotY);
        }

    }
}
