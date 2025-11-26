using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    [SerializeField] Animator frogAnimator;
    [SerializeField] MoveCamera moveCamera;
    Rigidbody playerRigidbody;
    Dictionary<string, float> directions = new Dictionary<string, float> // WSAD movement directions
    {
        {"forward", 0f},
        {"left", 270f},
        {"right", 90f},
        {"back", 180f}
    };
    // Vectors used to calculate movement
    Vector3 frogHalfExtents = new(0.325f, 0.15f, 0.325f);
    Vector3 originalPosition;
    Vector3 targetPosition;
    Vector3 originalRotation;
    Vector3 targetRotation;
    // Time for movement
    float timeToMove = 0.15f;
    float timeToJump = 0.15f;
    float timeToPressBounce = 0.5f;
    // Movement bools to check stuff
    int isOnWall = 0; // Collision counter
    bool isMoving = false;
    bool resetMovement = false;
    public bool isJumpAllowed = true;
    bool isJumping = false;
    bool canBounce = false;
    bool isBouncing = false;
    bool hasWall;
    bool canMove;
    bool canJump;

    //=====================================================================================================
    // Start and Update
    //=====================================================================================================

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        playerRigidbody = GetComponent<Rigidbody>();
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
        canMove = (IsGrounded() || isOnWall > 0) && !isMoving && !isJumping;
        canJump = !isMoving && IsGrounded() && isJumpAllowed;

        if (Input.GetKeyDown(KeyCode.W) && canMove)
        {
            RotatePlayer("forward");
            StartCoroutine(MovePlayerOnGrid());
        }

        if (Input.GetKeyDown(KeyCode.S) && canMove)
        {
            RotatePlayer("back");
            StartCoroutine(MovePlayerOnGrid());
        }

        if (Input.GetKeyDown(KeyCode.A) && canMove)
        {
            RotatePlayer("left");
            StartCoroutine(MovePlayerOnGrid());
        }

        if (Input.GetKeyDown(KeyCode.D) && canMove)
        {
            RotatePlayer("right");
            StartCoroutine(MovePlayerOnGrid());
        }

        if (Input.GetKeyDown(KeyCode.Space) && canJump)
        {
            if (!isJumping)
            {
                frogAnimator.SetTrigger("JumpTrigger");
                SoundManager.PlaySound(SoundType.FrogJump);
                JumpUp(); 
            }
        }
    }

    //=====================================================================================================
    // Unity methods
    //=====================================================================================================
    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Outside") && !isJumping && !isMoving && !isBouncing)
        {
            // Check where the player is colliding with the block
            Vector3 normal = collision.contacts[collision.contactCount - 1].normal;

            // If player is out of the hole show win menu
            if (normal.y > 0.5f) { GameObject.Find("WinMenu").GetComponent<WinMenuController>().ShowWinMenu();
                SoundManager.PlaySound(SoundType.Win);
            } 
        }

        if (collision.gameObject.CompareTag("Block") || collision.gameObject.CompareTag("Wall") || collision.gameObject.CompareTag("Outside"))
        {
            if (IsGrounded()) { moveCamera.ChangeCameraHeight(transform.position.y); } // Trigger camera movement
            if (isJumping) { isOnWall++; }

            // Check where the player is colliding with the block
            Vector3 normal = collision.contacts[collision.contactCount - 1].normal;
            if (normal.y > 0.5f) { return; } // If player is moving between blocks don't reset movement

            if (isMoving) { resetMovement = true; }
        }
    }

    void OnCollisionExit(Collision collision)
    {
        if (collision.gameObject.CompareTag("Block") || collision.gameObject.CompareTag("Wall") || collision.gameObject.CompareTag("Outside"))
        {
            if (isJumping && isOnWall > 0) { isOnWall--; }
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("DeathTrigger"))
        {
            GameObject.Find("DeathMenu").GetComponent<DeathMenuController>().ShowDeathMenu();
            SoundManager.PlaySound(SoundType.Lose, 0.4f);
            SoundManager.PlaySound(SoundType.Death, 0.5f);
        }
    }

    //=====================================================================================================
    // Custom methods
    //=====================================================================================================
    bool IsGrounded() // Check if player is on ground
    {
        Vector3 halfExtents = new Vector3(0.325f, 0.15f, 0.325f); // Frog half extents
        Vector3 checkPos = transform.position + Vector3.down * 0.15f;
        int blockMask = 192; // 64 = mask 6 == Wall (includes blocks, ground and outside)

        return Physics.CheckBox(checkPos, halfExtents, transform.rotation, blockMask);
    }

    void RotatePlayer(string direction) // Rotate player in direction of movement
    {
        transform.eulerAngles = new Vector3(0, directions[direction], 0);
    }

    IEnumerator MovePlayerOnGrid() // Move player on the 2D grid
    {
        frogAnimator.SetTrigger("MovementTrigger");
        isMoving = true; // Mark movement
        float startTime = Time.time; // Start counting time

        // Calculate positions
        originalPosition = transform.position;
        targetPosition = originalPosition + transform.forward;

        // Lerp to the target position
        while (true)
        {
            float currentTime = Mathf.Clamp01(Time.time - startTime) / timeToMove; // Count time during movement
            if(currentTime >= 1f || resetMovement) break; // Break if the movement time passed

            transform.position = Vector3.Lerp(originalPosition, targetPosition, currentTime);
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
        float startTime = Time.time; // Start counting time

        // Calculate positions
        originalPosition = transform.position;
        targetPosition = originalPosition + targetPositionShift;

        // Calculate rotations
        originalRotation = transform.eulerAngles;
        targetRotation = originalRotation + targetRotationShift;

        Collider[] hits = Physics.OverlapBox(targetPosition, frogHalfExtents, Quaternion.Euler(targetRotation));
        hasWall = false;

        foreach(var hit in hits)
        {
            if (!hit.isTrigger)
            {
                hasWall = true;
                break;
            }
        }

        // Lerp to the target position and rotation
        while (true)
        {
            float currentTime = Mathf.Clamp01((Time.time - startTime) / timeForMovement); // Count time during movement
            if(currentTime >= 1f) break; // Break if the movement time passed

            transform.position = Vector3.Lerp(originalPosition, targetPosition, currentTime);
            transform.eulerAngles = Vector3.Lerp(originalRotation, targetRotation, currentTime);
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
            if (isOnWall > 0 || hasWall) { StartCoroutine(AwaitBounce()); }
            else { FallForwad(); }
        }));
    }

    void BounceUp() // Bounce from the wall in the other direction
    {
        StopAllCoroutines();
        // canBounce = false;
        isBouncing = true;
        playerRigidbody.useGravity = true;
        
        StartCoroutine(MovePlayerIn3D(transform.forward + transform.up * 0.7f, new Vector3(0, 180, 0), timeToJump, () =>
        {
            isBouncing = false;
            if (isOnWall > 0 || hasWall) { StartCoroutine(AwaitBounce()); }
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
        playerRigidbody.useGravity = false;
        playerRigidbody.linearVelocity = Vector3.zero;

        // Wait for input
        float timer = 0f;
        while (timer < timeToPressBounce)
        {
            if(Input.GetKeyDown(KeyCode.Space))
            {
                canBounce = false;
                frogAnimator.SetTrigger("JumpTrigger");
                SoundManager.PlaySound(SoundType.FrogJump);
                BounceUp(); 
                break;
            }

            timer += Time.deltaTime;
            yield return null;
        }

        playerRigidbody.useGravity = true; // Turn the gravity back on

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
