using System;
using UnityEngine;

public class BlockFall : MonoBehaviour
{
    [SerializeField] GameObject lights;
    float fallingVelocity = 7.5f;
    bool stop = false;
    int levelHeight;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        levelHeight = GameObject.Find("BlockSpawner").GetComponent<BlockSpawnerController>().levelHeight;
    }

    // Update is called once per frame
    void Update()
    {
        if (!stop) { transform.position += Vector3.down * fallingVelocity * Time.deltaTime; }
        if (transform.position.y < -10) { Destroy(gameObject); }
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

                Destroy(lights); // Turn off the lights

                // Snap to position
                float snapY = (float)Math.Round(transform.position.y - 0.5f) + 0.5f;
                RaycastHit hit;

                if (!Physics.BoxCast(transform.position, transform.localScale * 0.5f * 0.99f, Vector3.down,
                    out hit, Quaternion.identity, transform.position.y - snapY))
                { transform.position = new Vector3(transform.position.x, snapY, transform.position.z); }
                else
                {
                    // Adjust snap to be above the block below
                    transform.position = new Vector3(transform.position.x, hit.point.y + 0.5f, transform.position.z);
                }

                if (transform.position.y > levelHeight + 3) // Destory blocks that aren't in the hole when they stop falling
                {
                    Destroy(gameObject);
                }
            }
        }
    }
}
