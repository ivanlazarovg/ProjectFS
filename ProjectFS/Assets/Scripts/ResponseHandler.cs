using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class ResponseHandler : MonoBehaviour
{
    public bool isResponding;
    public ResponseObject[] responses;
    public ResponseObject pickedResponse;
    public GameObject responsePoint;
    [SerializeField] private RectTransform responseTemplate;
    [SerializeField] private RectTransform responseContainer;
    private List<GameObject> tempButtonList = new List<GameObject>();

    public void ShowResponses(ResponseObject[] responses)
    {
        responsePoint.SetActive(true);

        foreach(ResponseObject response in responses)
        {
            GameObject responseButton = Instantiate(responseTemplate.gameObject, responseContainer);
            tempButtonList.Add(responseButton);
            responseButton.gameObject.SetActive(true);
            responseButton.GetComponentInChildren<TMP_Text>().text = response.text;          
            responseButton.GetComponent<Button>().onClick.AddListener(() => OnChosenResponse(response));
            
        }
    }

    public void OnChosenResponse(ResponseObject response)
    {  
        responsePoint.SetActive(false);

        foreach (var button in tempButtonList) Destroy(button);
        tempButtonList.Clear();

        pickedResponse = response;
        isResponding = false;
    }
}
