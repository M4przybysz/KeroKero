using System.Collections;
using UnityEngine;

public class RotateCamera : MonoBehaviour
{
    [SerializeField] PlayerController playerController;

    Vector3 originalRotation;
    Vector3 targetRotation;
    float timeToRotate = 0.25f;
    int direction = 0;
    bool isMoving = false;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        HandleInputs();
    }

    void HandleInputs() 
    {
        if ((Input.GetKeyDown(KeyCode.Q) || Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.Mouse0)) &&
            !isMoving &&
            GameObject.Find("PauseMenu").GetComponent<PauseMenuController>().isPauseOn == false)
        {
            direction = 1;
            StartCoroutine(Rotatation(direction));
            playerController.RotateDirections(90);
        }

        if((Input.GetKeyDown(KeyCode.E) || Input.GetKeyDown(KeyCode.RightArrow) || Input.GetKeyDown(KeyCode.Mouse1)) &&
            !isMoving &&
            GameObject.Find("PauseMenu").GetComponent<PauseMenuController>().isPauseOn == false)
        {
            direction = -1;
            StartCoroutine(Rotatation(direction));
            playerController.RotateDirections(-90);
        }
    }

    IEnumerator Rotatation(int direction)
    {
        isMoving = true; // Mark cameramovement
        float startTime = Time.time; // Start counting time

        // Calculate rotations
        originalRotation = transform.eulerAngles;
        targetRotation = transform.eulerAngles + new Vector3(0, 90 * direction, 0);

        // Lerp to target rotation
        while(isMoving)
        {
            float currentTime = Mathf.Clamp01((Time.time - startTime) / timeToRotate); // Count time during movement
            if(currentTime >= 1f) break; // Break if the movement time passed

            transform.eulerAngles = Vector3.Lerp(originalRotation, targetRotation, currentTime);
            yield return null;
        }

        transform.eulerAngles = targetRotation; // Snap to position
        isMoving = false; // Unmark movement
    }
}
