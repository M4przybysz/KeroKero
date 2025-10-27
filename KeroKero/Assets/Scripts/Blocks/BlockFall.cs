using System;
using TreeEditor;
using UnityEngine;

public class BlockFall : MonoBehaviour
{
    float fallingVelocity = 7.5f;
    bool stop = false;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (!stop) { transform.position += Vector3.down * fallingVelocity * Time.deltaTime; }
    }

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Block"))
        {
            Vector3 normal = collision.contacts[collision.contactCount - 1].normal;
            if (normal.y > 0.5f && normal.z < 0.5f && normal.z > -0.5f && normal.x < 0.5f && normal.x > -0.5f)
            {
                gameObject.GetComponent<BlockRandomMovement>().StopRandomMovement(); // Stop random movment and rotation
                stop = true; // Stop falling

                // Snap to position
                transform.position = new Vector3(
                    transform.position.x,
                    (float)Math.Round(transform.position.y * 2, MidpointRounding.AwayFromZero) / 2,
                    transform.position.z);

                if (transform.position.y % 2 == 0) // Bug fix
                {
                    transform.position = new Vector3(transform.position.x, transform.position.y + 0.5f, transform.position.z);
                }
                
                if(transform.position.y > 13) // Destory blocks that aren't in the hole when they stop falling
                {
                    Destroy(gameObject);
                }
            }
        }
    }
}
