using UnityEngine;

public class SyncXRay : MonoBehaviour
{
    public static int posID = Shader.PropertyToID("_Player_Position");
    public static int distanceID = Shader.PropertyToID("_Player_Distance");
    public static int sizeID = Shader.PropertyToID("_Size");

    [SerializeField] Material[] blockMaterials;
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
            foreach(Material bm in blockMaterials) { bm.SetFloat(sizeID, 1.25f); }
        }
        else
        {
            foreach(Material bm in blockMaterials) { bm.SetFloat(sizeID, 0); }
        }

        Vector3 view = mainCamera.WorldToViewportPoint(transform.position);
        foreach(Material bm in blockMaterials) { bm.SetVector(posID, view); }

        float distanceToCamera = Vector3.Distance(transform.position, mainCamera.transform.position);
        foreach(Material bm in blockMaterials) { bm.SetFloat(distanceID, distanceToCamera); }
    }
}
