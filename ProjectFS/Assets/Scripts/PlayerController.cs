using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{

    public float speed;
    public float jump;
    float moveVelocity;

    bool isGrounded = true;
    private Rigidbody rb;

    private void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space) || Input.GetKeyDown(KeyCode.UpArrow) || Input.GetKeyDown(KeyCode.W))
        {
            if (isGrounded)
            {
                rb.AddForce(new Vector3(0, jump, 0), ForceMode.Impulse);
                isGrounded = false;
            }
        }

        moveVelocity = 0;

        if (Input.GetKey(KeyCode.LeftArrow) || Input.GetKey(KeyCode.A))
        {
            moveVelocity = -speed;
        }
        if (Input.GetKey(KeyCode.RightArrow) || Input.GetKey(KeyCode.D))
        {
            moveVelocity = speed;
        }

        rb.velocity = new Vector2(moveVelocity, rb.velocity.y);

    }
    private void OnCollisionEnter(Collision collision)
    {
        isGrounded = true;
    }
}
