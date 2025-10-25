using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    [SerializeField] MoveCamera moveCamera;
    Dictionary<string, float> directions = new Dictionary<string, float> // WSAD movement directions
    {
        {"forward", 0f},
        {"left", 270f},
        {"right", 90f},
        {"back", 180f}
    };
    // Vectors used to calculate movement
    Vector3 originalPosition;
    Vector3 targetPosition;
    Vector3 originalRotation;
    Vector3 targetRotation;
    // Time for movement
    float timeToMove = 0.15f;
    float timeToJump = 0.15f;
    float timeToPressBounce = 0.5f;
    // Movement bools to check stuff
    int isOnWall = 0; // Collision counter (I know it's not a bool)
    int isInAir = 0;
    bool isMoving = false;
    bool resetMovement = false;
    public bool canJump = true;
    bool isJumping = false;
    bool canBounce = false;
    bool isBouncing = false;

    //=====================================================================================================
    // Start and Update
    //=====================================================================================================

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

    //=====================================================================================================
    // Input handling
    //=====================================================================================================
    void HandleInputs()
    {
        if (Input.GetKeyDown(KeyCode.W) && !isMoving && !isJumping && isInAir == -1)
        {
            RotatePlayer("forward");
            StartCoroutine(MovePlayerOnGrid());
        }

        if (Input.GetKeyDown(KeyCode.S) && !isMoving && !isJumping && isInAir == -1)
        {
            RotatePlayer("back");
            StartCoroutine(MovePlayerOnGrid());
        }

        if (Input.GetKeyDown(KeyCode.A) && !isMoving && !isJumping && isInAir == -1)
        {
            RotatePlayer("left");
            StartCoroutine(MovePlayerOnGrid());
        }

        if (Input.GetKeyDown(KeyCode.D) && !isMoving && !isJumping && isInAir == -1)
        {
            RotatePlayer("right");
            StartCoroutine(MovePlayerOnGrid());
        }

        if (Input.GetKeyDown(KeyCode.Space) && !isMoving && isInAir == -1 && canJump)
        {
            if (!isJumping) { JumpUp(); }
            if (canBounce) { BounceUp(); }
        }
    }

    //=====================================================================================================
    // Unity methods
    //=====================================================================================================
    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Block") || collision.gameObject.CompareTag("Wall"))
        {
            isInAir--;
            if (isInAir == -1) { moveCamera.ChangeCameraHeight(transform.position.y); } // Trigger camera movement
            if (isJumping) { isOnWall++; }

            // Check where the player is colliding with the block
            Vector3 normal = collision.contacts[collision.contactCount-1].normal;
            if (normal.y > 0.5f) { return; } // If player is moving between blocks don't reset movement

            if (isMoving) { resetMovement = true; }
        }
    }

    void OnCollisionExit(Collision collision)
    {
        if (collision.gameObject.CompareTag("Block") || collision.gameObject.CompareTag("Wall"))
        {
            isInAir++;
            if (isJumping && isOnWall > 0) { isOnWall--; }
        }
    }

    //=====================================================================================================
    // Custom methods
    //=====================================================================================================
    void RotatePlayer(string direction) // Rotate player in direction of movement
    {
        transform.eulerAngles = new Vector3(0, directions[direction], 0);
    }

    IEnumerator MovePlayerOnGrid() // Move player on the 2D grid
    {
        isMoving = true; // Mark movement
        float elapsedTime = 0f; // Start counting time

        // Calculate positions
        originalPosition = transform.position;
        targetPosition = originalPosition + transform.forward;

        // Lerp to the target position
        while (elapsedTime < timeToMove && !resetMovement)
        {
            transform.position = Vector3.Lerp(originalPosition, targetPosition, elapsedTime / timeToMove);
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        
        if (resetMovement)
        {
            // Snap to the starting position if movment is reset
            transform.position = originalPosition;
            resetMovement = false;
        }
        else { transform.position = targetPosition; } // Snap into the position in case something is off

        isMoving = false; // Unmark movement
    }

    // Move and rotate player in 3D space 
    IEnumerator MovePlayerIn3D(Vector3 targetPositionShift, Vector3 targetRotationShift, float timeForMovement, Action afterwork)
    {
        float elapsedTime = 0f; // Start counting time

        // Calculate positions
        originalPosition = transform.position;
        targetPosition = originalPosition + targetPositionShift;

        // Calculate rotations
        originalRotation = transform.eulerAngles;
        targetRotation = originalRotation + targetRotationShift;

        // Lerp to the target position and rotation
        while (elapsedTime < timeForMovement)
        {
            transform.position = Vector3.Lerp(originalPosition, targetPosition, elapsedTime / timeForMovement);
            transform.eulerAngles = Vector3.Lerp(originalRotation, targetRotation, elapsedTime / timeForMovement);
            elapsedTime += Time.deltaTime; // Count time
            yield return null;
        }

        // Snap into the position and rotation in case something is off
        transform.position = targetPosition;
        transform.eulerAngles = targetRotation;

        afterwork(); // Do whatever needs to be done after getting to the position
    }

    void JumpUp() // Jump up forward
    {
        isJumping = true;
        StartCoroutine(MovePlayerIn3D(transform.forward * 0.35f + transform.up * 1.35f, new Vector3(-90, 0, 0), timeToJump, () =>
        {
            if (isOnWall > 0) { StartCoroutine(AwaitBounce()); }
            else { FallForwad(); }
        }));
    }

    void BounceUp() // Bounce from the wall in the other direction
    {
        canBounce = false;
        isBouncing = true;
        StopAllCoroutines();
        gameObject.GetComponent<Rigidbody>().useGravity = true;
        
        StartCoroutine(MovePlayerIn3D(transform.forward + transform.up * 0.7f, new Vector3(0, 180, 0), timeToJump, () =>
        {
            isBouncing = false;
            if (isOnWall > 0) { StartCoroutine(AwaitBounce()); }
            else { FallForwad(); }
        }));
    }

    void FallForwad() // Finish the jump by falling onto the grid
    {
        StartCoroutine(MovePlayerIn3D(-transform.up * 0.65f, new Vector3(90, 0, 0), timeToJump, () => { isJumping = false; }));
    }

    void FallBack() // Return to the ground if player doen't bounce
    {
        StartCoroutine(MovePlayerIn3D(transform.up * 0.35f, new Vector3(90, 0, 0), timeToJump, () => { isJumping = false; }));
    }

    // Wait for bounce input
    IEnumerator AwaitBounce()
    {
        canBounce = true; // Allow bouncing

        // Stop player on wall
        gameObject.GetComponent<Rigidbody>().useGravity = false;
        gameObject.GetComponent<Rigidbody>().linearVelocity = Vector3.zero;

        yield return new WaitForSeconds(timeToPressBounce); // Waiting for input

        gameObject.GetComponent<Rigidbody>().useGravity = true; // Turn the gravity back on

        if (canBounce && !isBouncing)
        {
            canBounce = false; // Disable bouncing
            FallBack(); // Return to the ground
        }
    }

    public void RotateDirections(float angle) // Rotate movement angles relative to the camera movement
    {
        directions["forward"] += angle;
        directions["left"] += angle;
        directions["right"] += angle;
        directions["back"] += angle;
    }
}
