using UnityEngine;

public class BlockLight : MonoBehaviour
{
    // Update is called once per frame
    void Update()
    {
        if(transform.eulerAngles != new Vector3(90, 0, 0))
        {
            transform.eulerAngles = new Vector3(90, 0, 0);
        }
    }
}
