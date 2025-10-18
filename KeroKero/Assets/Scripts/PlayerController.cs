using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    Dictionary<string, float> directions = new Dictionary<string, float>
    {
        {"forward", 0f},
        {"left", 270f},
        {"right", 90f},
        {"back", 180f}
    };
    Vector3 originalPosition;
    Vector3 targetPosition;
    float timeToMove = 0.15f;
    bool isMoving = false;
    bool resetMovement = false;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        resetMovement = false;
    }

    // Update is called once per frame
    void Update()
    {
        HandleInputs();
    }

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Block"))
        {
            resetMovement = true;
        }
    }

    void HandleInputs()
    {
        if (Input.GetKeyDown(KeyCode.W) && !isMoving)
        {
            RotatePlayer("forward");
            StartCoroutine(MovePlayer());
        }

        if (Input.GetKeyDown(KeyCode.S) && !isMoving)
        {
            RotatePlayer("back");
            StartCoroutine(MovePlayer());
        }

        if (Input.GetKeyDown(KeyCode.A) && !isMoving)
        {
            RotatePlayer("left");
            StartCoroutine(MovePlayer());
        }

        if (Input.GetKeyDown(KeyCode.D) && !isMoving)
        {
            RotatePlayer("right");
            StartCoroutine(MovePlayer());
        }
    }

    void RotatePlayer(string direction)
    {
        transform.eulerAngles = new Vector3(0, directions[direction], 0);
    }

    IEnumerator MovePlayer()
    {
        isMoving = true;
        float elapsedTime = 0f;

        originalPosition = transform.position;
        targetPosition = originalPosition + transform.forward;

        while (elapsedTime < timeToMove && !resetMovement)
        {
            transform.position = Vector3.Lerp(originalPosition, targetPosition, elapsedTime / timeToMove);
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        if (resetMovement)
        {
            transform.position = originalPosition;
            resetMovement = false;
        }
        else
        {
            transform.position = targetPosition;
        }

        // transform.position = new Vector3(Mathf.Round(transform.position.x), transform.position.x, Mathf.Round(transform.position.x));

        isMoving = false;
    }
    
    public void RotateDirections(float angle)
    {
        directions["forward"] += angle;
        directions["left"] += angle;
        directions["right"] += angle;
        directions["back"] += angle;
    }
}
