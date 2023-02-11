using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Beam : MonoBehaviour
{
    [SerializeField] LineRenderer beamRenderer;
    public float castSpeed;
    public Transform heartTransform;
    public Transform targetObject;
    public bool isDissolving = false;
    float acceleration = 1;
    [SerializeField] float accelerationRate = 0.01f;
    float t = 0;
    public float dissipateSpeed;
    public Material beamMat;
    float alphaOrigin;
    [SerializeField] float alphaTarget;
    [SerializeField] float thinOutFloat;

    private void Start()
    {
        beamRenderer.SetPosition(beamRenderer.positionCount - 1, heartTransform.position);
        beamMat.SetFloat("_Alpha", 1);
        alphaOrigin = beamMat.GetFloat("_Alpha");
    }
    // Update is called once per frame
    void Update()
    {
        Cast();

        if (isDissolving)
        {
            Dissolve();
        }
    }

    public void Cast()
    {
        beamRenderer.SetPosition(0, heartTransform.position);
        acceleration += accelerationRate;
        float time = castSpeed * Time.deltaTime * acceleration;
        Vector3 movingPosition = Vector3.MoveTowards(beamRenderer.GetPosition(beamRenderer.positionCount - 1), targetObject.position, time);
        beamRenderer.SetPosition(beamRenderer.positionCount - 1, movingPosition);
        if(Vector3.Distance(targetObject.position, beamRenderer.GetPosition(beamRenderer.positionCount - 1)) <= 0.01f)
        {
            //targetObject.parent.GetComponent<Dissolve>().isDissolving = true;
        }
    }

    public void Dissolve()
    {
        t += Time.deltaTime * dissipateSpeed;
        beamMat.SetFloat("_Alpha", Mathf.Lerp(alphaOrigin, alphaTarget, t));
        beamRenderer.startWidth -= thinOutFloat;
        beamRenderer.endWidth -= thinOutFloat;
        if(beamMat.GetFloat("_Alpha") <= alphaTarget)
        {
            Destroy(this.gameObject);
        }
    }

    public void SetTarget(Transform target, Transform heart)
    {
        targetObject = target;
        heartTransform = heart;
    }
}
