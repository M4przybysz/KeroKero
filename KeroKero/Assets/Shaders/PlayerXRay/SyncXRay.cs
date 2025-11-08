using UnityEngine;

public class SyncXRay : MonoBehaviour
{
    public static int posID = Shader.PropertyToID("_Player_Position");
    public static int sizeID = Shader.PropertyToID("_Size");

    [SerializeField] Material wallMaterial;
    [SerializeField] Camera mainCamera;
    [SerializeField] LayerMask mask;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 direction = mainCamera.transform.position - transform.position;
        Ray ray = new Ray(transform.position, direction.normalized);

        if (Physics.Raycast(ray, 3000, mask))
        {
            wallMaterial.SetFloat(sizeID, 1);
        }
        else
        {
            wallMaterial.SetFloat(sizeID, 0);
        }

        Vector3 view = mainCamera.WorldToViewportPoint(transform.position);
        wallMaterial.SetVector(posID, view);
    }
}
