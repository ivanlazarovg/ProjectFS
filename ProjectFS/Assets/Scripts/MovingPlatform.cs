using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovingPlatform : MonoBehaviour
{
    public Transform point1;
    public Transform point2;
    float timer;
    float time = 0;
    public float movingSpeed;

    void Update()
    {
        time += Time.deltaTime * movingSpeed;
        timer = Mathf.PingPong(time, 1);
        transform.position = Vector3.Lerp(point1.position, point2.position, timer);
    }
}
