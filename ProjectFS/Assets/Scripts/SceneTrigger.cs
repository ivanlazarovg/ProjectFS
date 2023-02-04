using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class SceneTrigger : MonoBehaviour
{
    [SerializeField]
    private float radius;
    public SceneAct[] sceneActs;
    public bool isSceneActive;
    public LayerMask layerMask;
    public bool isAdded = false;
    public Speaker speaker;

    private void Update()
    {

        if (Physics.CheckSphere(transform.position, radius, layerMask, QueryTriggerInteraction.Ignore))
        {
            if (Input.GetKeyDown(KeyCode.T))
            {
                speaker.Talk();
            }
            isSceneActive = true;
            Debug.Log("isHitting");
        }
        else 
        {
            if (radius != 0)
            {
                isSceneActive = false;
            }

        }


    }
}
