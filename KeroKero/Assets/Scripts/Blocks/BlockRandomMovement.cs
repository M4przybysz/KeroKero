using UnityEngine;

public class BlockRandomMovement : MonoBehaviour
{
    [SerializeField] Transform ghost;
    bool stop = false;
    int randomMovementChance = 2; // 1/2 chance to trigger random movement
    int randomRotationChance = 2; // 1/2 chance to trigger random rotation 
    float tickDelay = 0.5f;
    int levelHeight;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        levelHeight = GameObject.Find("BlockSpawner").GetComponent<BlockSpawnerController>().levelHeight;
        InvokeRepeating(nameof(RandomMovementAndRotation), tickDelay, tickDelay);
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void StopRandomMovement()
    {
        stop = true; // Stop random movement and rotation
        ghost.position = transform.position; // Return ghost to normal position
        ghost.eulerAngles = transform.eulerAngles; // Return ghost to normal rotation
    }

    void RandomMovementAndRotation()
    {
        if(!stop && transform.position.y > levelHeight + 8)
        {
            // bool doMovement = true;
            bool doMovement = (Random.Range(1, randomMovementChance + 1) == 1) ? true : false; // Gample to trigger random movement
            bool doRotation = (Random.Range(1, randomRotationChance + 1) == 1) ? true : false; // Gample to trigger random rotation

            if (doMovement)
            {
                bool cancelMovement = false;

                // Randomly change ghost's x and z position
                ghost.position = new Vector3(transform.position.x + Random.Range(-1, 2), transform.position.y, transform.position.z + Random.Range(-1, 2));

                for (int i = 0; i < ghost.childCount; i++)
                {
                    // Check if any ghost block is out of level bounds  
                    if (ghost.GetChild(i).position.x > 4.5f || ghost.GetChild(i).position.x < -4.5f ||
                        ghost.GetChild(i).position.z > 4.5f || ghost.GetChild(i).position.z < -4.5f)
                    {
                        ghost.position = transform.position;
                        cancelMovement = true; // Reset ghost position and reset movement if it would be out of bounds
                    }
                }
                
                if (!cancelMovement)
                {
                    transform.position = ghost.position; // Move entire block to the ghost's position
                    ghost.position = transform.position; // Return the ghost to block's inside
                }
            }
            
            if (doRotation)
            {
                bool cancelRotation = false;

                // Randomly change ghost's rotation
                ghost.eulerAngles = new Vector3(transform.eulerAngles.x + 90 * Random.Range(0, 2), transform.eulerAngles.y + 90 * Random.Range(0, 2), transform.eulerAngles.z + 90 * Random.Range(0, 2));

                for (int i = 0; i < ghost.childCount; i++)
                {
                    // Check if any ghost block is out of level bounds  
                    if (ghost.GetChild(i).position.x > 4.5f || ghost.GetChild(i).position.x < -4.5f ||
                        ghost.GetChild(i).position.z > 4.5f || ghost.GetChild(i).position.z < -4.5f)
                    {
                        ghost.localEulerAngles = Vector3.zero;
                        cancelRotation = true; // Reset ghost position and reset movement if it would be out of bounds
                    }
                }
                
                if(!cancelRotation)
                {
                    transform.eulerAngles = ghost.eulerAngles; // Rotate entire block to the ghost's rotation
                    ghost.localEulerAngles = Vector3.zero; // Return the ghost to block's inside
                }
            }
        }
    }
}
