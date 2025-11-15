using UnityEngine;

public class LooseBlockFall : MonoBehaviour
{
    float fallingVelocity = 7.5f;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.position += Vector3.down * fallingVelocity * Time.deltaTime;

        if(transform.childCount == 1 || transform.position.y < -10)
        {
            Destroy(gameObject);
        }
    }
}
