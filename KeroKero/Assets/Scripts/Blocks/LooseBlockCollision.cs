using System;
using UnityEngine;

public class LooseBlockCollision : MonoBehaviour
{
    int levelHeight;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        levelHeight = GameObject.Find("BlockSpawner").GetComponent<BlockSpawnerController>().levelHeight;
    }

    // Update is called once per frame
    void Update()
    {

    }
    
    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Block"))
        {
            Vector3 normal = collision.contacts[collision.contactCount - 1].normal;
            if (normal.y > 0.5f)
            {
                gameObject.tag = "Block";

                transform.parent = null; // Detach from block to stop falling

                // Snap to position
                transform.position = new Vector3(
                    transform.position.x,
                    (float)Math.Round(transform.position.y - 0.5f) + 0.5f,
                    transform.position.z);

                if (transform.position.y % 2 == 0) // Bug fix
                {
                    transform.position = new Vector3(transform.position.x, transform.position.y + 0.5f, transform.position.z);
                }

                if (transform.position.y > levelHeight + 2) // Destory blocks that aren't in the hole when they stop falling
                {
                    Destroy(gameObject);
                }
            }
        }
    }
}
