using UnityEngine;

public class RotateCamera : MonoBehaviour
{
    [SerializeField] PlayerController playerController;

    float targetRotation;
    float speed = 400f;
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

        // Rotate camera
        if (isMoving)
        {
            transform.Rotate(Vector3.up, direction * speed * Time.deltaTime);
            targetRotation -= speed * Time.deltaTime;

            if (targetRotation < 0)
            {
                transform.eulerAngles += new Vector3(0, direction * targetRotation, 0);
                isMoving = false;
            }
        }
    }

    void HandleInputs() 
    {
        if (Input.GetKeyDown(KeyCode.Q) && !isMoving)
        {
            direction = 1;
            targetRotation = 90;
            isMoving = true;
            playerController.RotateDirections(90);
        }

        if(Input.GetKeyDown(KeyCode.E) && !isMoving)
        {
            direction = -1;
            targetRotation = 90;
            isMoving = true;
            playerController.RotateDirections(-90);
        }
    }
}
