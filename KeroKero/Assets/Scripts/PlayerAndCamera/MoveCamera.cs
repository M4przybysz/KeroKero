using System.Collections;
using UnityEngine;

public class MoveCamera : MonoBehaviour
{
    [SerializeField] PlayerController playerController;
    Vector3 originalPosition;
    Vector3 targetPosition;
    float timeToMove = 0.1f;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        // Smooth camera movement
        // transform.position = new Vector3(0, playerController.transform.position.y - 0.15f, 0);
    }

    public void ChangeCameraHeight(float height) // Camera movement trigger
    {
        StartCoroutine(CameraMovement(height));
    }
    
    IEnumerator CameraMovement(float height) // Move camera to specific position
    {
        float elapsedTime = 0f; // Start counting time

        // Calculate positions
        originalPosition = transform.position;
        targetPosition = new Vector3(0, height - 0.15f, 0);

        // Lerp to the target position
        while (elapsedTime < timeToMove)
        {
            transform.position = Vector3.Lerp(originalPosition, targetPosition, elapsedTime / timeToMove);
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        transform.position = targetPosition; // Snap into the position in case something is off
    }
}
