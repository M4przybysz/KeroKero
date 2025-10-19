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
    Vector3 originalRotation;
    Vector3 targetRotation;
    float timeToMove = 0.15f;
    float timeToJump = 0.15f;
    float timeToPressBounce = 0.5f;
    bool isMoving = false;
    bool isJumping = false;
    bool isOnWall = false;
    bool resetMovement = false;
    bool canBounce = false;

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

    void HandleInputs()
    {
        if (Input.GetKeyDown(KeyCode.W) && !isMoving && !isJumping)
        {
            RotatePlayer("forward");
            StartCoroutine(MovePlayer());
        }

        if (Input.GetKeyDown(KeyCode.S) && !isMoving && !isJumping)
        {
            RotatePlayer("back");
            StartCoroutine(MovePlayer());
        }

        if (Input.GetKeyDown(KeyCode.A) && !isMoving && !isJumping)
        {
            RotatePlayer("left");
            StartCoroutine(MovePlayer());
        }

        if (Input.GetKeyDown(KeyCode.D) && !isMoving && !isJumping)
        {
            RotatePlayer("right");
            StartCoroutine(MovePlayer());
        }

        if (Input.GetKeyDown(KeyCode.Space) && !isMoving)
        {
            if (!isJumping) { StartCoroutine(JumpUp()); }
            if (canBounce) { StartCoroutine(BounceUp()); }
        }
    }

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Block"))
        {
            if (isMoving) { resetMovement = true; }
            if (isJumping) { isOnWall = true; }
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
        else { transform.position = targetPosition; }

        isMoving = false;
    }

    IEnumerator JumpUp()
    {
        isJumping = true;
        float elapsedTime = 0f;

        originalPosition = transform.position;
        targetPosition = originalPosition + transform.forward * 0.4f + transform.up * 1.25f;

        originalRotation = transform.eulerAngles;
        targetRotation = originalRotation + new Vector3(-90, 0, 0);

        while (elapsedTime < timeToJump)
        {
            transform.position = Vector3.Lerp(originalPosition, targetPosition, elapsedTime / timeToJump);
            transform.eulerAngles = Vector3.Lerp(originalRotation, targetRotation, elapsedTime / timeToJump);
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        transform.position = targetPosition;
        transform.eulerAngles = targetRotation;

        if (isOnWall) { StartCoroutine(AwaitBounce()); }
        else { StartCoroutine(FallForwad()); }
    }

    IEnumerator AwaitBounce()
    {
        canBounce = true;
        gameObject.GetComponent<Rigidbody>().useGravity = false;
        gameObject.GetComponent<Rigidbody>().linearVelocity = Vector3.zero;

        yield return new WaitForSeconds(timeToPressBounce);

        gameObject.GetComponent<Rigidbody>().useGravity = true;
        isOnWall = false;

        if (canBounce)
        {
            canBounce = false;
            StartCoroutine(FallBack());
        }
    }

    IEnumerator BounceUp()
    {
        canBounce = false;
        gameObject.GetComponent<Rigidbody>().useGravity = true;
        float elapsedTime = 0f;

        originalPosition = transform.position;
        targetPosition = originalPosition + transform.forward + transform.up * 1.4f;

        originalRotation = transform.eulerAngles;
        targetRotation = originalRotation + new Vector3(90, 180, 0);

        while (elapsedTime < timeToJump)
        {
            transform.position = Vector3.Lerp(originalPosition, targetPosition, elapsedTime / timeToJump);
            transform.eulerAngles = Vector3.Lerp(originalRotation, targetRotation, elapsedTime / timeToJump);
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        transform.position = targetPosition;
        transform.eulerAngles = targetRotation;

        isJumping = false;
    }

    IEnumerator FallForwad()
    {
        float elapsedTime = 0f;

        originalPosition = transform.position;
        targetPosition = originalPosition + -transform.up * 0.6f;

        originalRotation = transform.eulerAngles;
        targetRotation = originalRotation + new Vector3(90, 0, 0);

        while (elapsedTime < timeToJump)
        {
            transform.position = Vector3.Lerp(originalPosition, targetPosition, elapsedTime / timeToJump);
            transform.eulerAngles = Vector3.Lerp(originalRotation, targetRotation, elapsedTime / timeToJump);
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        transform.position = targetPosition;
        transform.eulerAngles = targetRotation;

        isJumping = false;
    }

    IEnumerator FallBack()
    {
        float elapsedTime = 0f;

        originalPosition = transform.position;
        targetPosition = originalPosition + transform.up * 0.4f;

        originalRotation = transform.eulerAngles;
        targetRotation = originalRotation + new Vector3(90, 0, 0);

        while (elapsedTime < timeToJump)
        {
            transform.position = Vector3.Lerp(originalPosition, targetPosition, elapsedTime / timeToJump);
            transform.eulerAngles = Vector3.Lerp(originalRotation, targetRotation, elapsedTime / timeToJump);
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        transform.position = targetPosition;
        transform.eulerAngles = targetRotation;

        isJumping = false;
    }

    public void RotateDirections(float angle)
    {
        directions["forward"] += angle;
        directions["left"] += angle;
        directions["right"] += angle;
        directions["back"] += angle;
    }
}
