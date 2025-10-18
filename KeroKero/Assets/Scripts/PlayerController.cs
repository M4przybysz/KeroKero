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
    float movementSpeed = 100;

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
        if (Input.GetKeyDown(KeyCode.W))
        {
            RotatePlayer("forward");
        }

        if (Input.GetKeyDown(KeyCode.S))
        {
            RotatePlayer("back");
        }

        if (Input.GetKeyDown(KeyCode.A))
        {
            RotatePlayer("left");
        }

        if (Input.GetKeyDown(KeyCode.D))
        {
            RotatePlayer("right");
        }
    }

    void RotatePlayer(string direction)
    {
        transform.eulerAngles = new Vector3(0, directions[direction], 0);
    }
    
    public void RotateDirections(float angle)
    {
        directions["forward"] += angle;
        directions["left"] += angle;
        directions["right"] += angle;
        directions["back"] += angle;
    }
}
