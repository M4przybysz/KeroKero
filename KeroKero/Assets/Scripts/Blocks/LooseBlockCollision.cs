using System;
using UnityEngine;

public class LooseBlockCollision : MonoBehaviour
{
    int levelHeight;
    [SerializeField] GameObject spotLight;

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
            if (normal.y > 0.5f && transform.parent != null)
            {
                int childCounter = 0;

                // Check other fragments of this loose block
                while (childCounter < transform.parent.childCount)
                {
                    Transform child = transform.parent.GetChild(childCounter); // Get the child

                    if (child == transform) { childCounter++;  continue; }

                    // Check if the child isn't the object that runs this code, if it's a loose block and if it's in the same collumn
                    if (child.gameObject.CompareTag("LooseBlock") &&
                        Mathf.Round(transform.position.x) == Mathf.Round(child.position.x) &&
                        Mathf.Round(transform.position.z) == Mathf.Round(child.position.z) )
                    {
                        child.gameObject.GetComponent<LooseBlockCollision>().SnapToPosition(); // Remove the child from the loose block
                    }
                    else { childCounter++; } // go to the next child if code wasn't executed
                }   
                
                SnapToPosition();
            }
        }
    }
    
    public void SnapToPosition()
    {
        gameObject.tag = "Block";

        transform.parent = null; // Detach from block to stop falling

        if (spotLight != null) { Destroy(spotLight); } // Turn off the light

        // Snap to position
        transform.position = new Vector3(
            transform.position.x,
            (float)Math.Round(transform.position.y - 0.5f) + 0.5f,
            transform.position.z);

        if (transform.position.y > levelHeight + 2) // Destory blocks that aren't in the hole when they stop falling
        {
            Destroy(gameObject);
        }
    }
}
