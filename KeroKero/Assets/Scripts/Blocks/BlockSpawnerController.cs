using UnityEngine;

public class BlockSpawnerController : MonoBehaviour
{
    [SerializeField] GameObject[] blocks;
    int spawnRangeX = 2;
    int spawnRangeZ = 2;
    float firsBlocSpawnkDelay = 1f;
    float blockSpawnDelay = 1.5f;
    public int blockCounterMax = 5;
    int blockCounter;
    public int levelHeight = 10;


    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        blockCounter = blockCounterMax;
        InvokeRepeating(nameof(SpawnRandomBlock), firsBlocSpawnkDelay, blockSpawnDelay);
    }

    // Update is called once per frame
    void Update()
    {

    }
    
    void SpawnRandomBlock()
    {
        // Choose random block and generate random position and rotation for it; 
        int blockIndex;
        if (blockCounter == 0) 
        {
            blockIndex = Random.Range(3, blocks.Length);
            blockCounter = 6; 
        } // Spawn any random block
        else { blockIndex = Random.Range(0, 3); } // Spawn random "basic" block
    
        Vector3 spawnPosition = new Vector3(Random.Range(-spawnRangeX, spawnRangeX+1), transform.position.y, Random.Range(-spawnRangeZ, spawnRangeZ+1));
        Vector3 spawnRotation = new Vector3(90 * Random.Range(-2, 2), 90 * Random.Range(-2, 2), 90 * Random.Range(-2, 2));

        Instantiate(blocks[blockIndex], spawnPosition, Quaternion.Euler(spawnRotation));

        blockCounter -= 1;
    }
}
