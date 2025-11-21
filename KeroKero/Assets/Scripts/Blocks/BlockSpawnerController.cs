using UnityEngine;

public class BlockSpawnerController : MonoBehaviour
{
    [SerializeField] GameObject[] blocks;
    int spawnRangeX = 2;
    int spawnRangeZ = 2;
    float firsBlocSpawnkDelay = 1f;
    float blockSpawnDelay = 1.5f;
    public int blockCounterMax;
    int blockCounter;
    public int levelHeight = 10;
    [SerializeField] int basicBlocksNumber, otherBlocksNumber;


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
            blockIndex = Random.Range(basicBlocksNumber, basicBlocksNumber + otherBlocksNumber - 1); // Spawn random other block
            blockCounter = blockCounterMax;
        }
        else { blockIndex = Random.Range(0, basicBlocksNumber); } // Spawn random "basic" block

        int positionX = Random.Range(1, spawnRangeX + 1);
        positionX *= Random.Range(0, 2) == 0 ? -1 : 1;

        int positionZ = Random.Range(1, spawnRangeZ + 1);
        positionZ *= Random.Range(0, 2) == 0 ? -1 : 1;

        Vector3 spawnPosition = new Vector3(positionX, transform.position.y, positionZ);
        Vector3 spawnRotation = new Vector3(90 * Random.Range(-2, 2), 90 * Random.Range(-2, 2), 90 * Random.Range(-2, 2));

        Instantiate(blocks[blockIndex], spawnPosition, Quaternion.Euler(spawnRotation));

        blockCounter--;
    }
}
