using UnityEngine;

public class JumpLimiter : MonoBehaviour
{
    [SerializeField] GameObject player;
    PlayerController playerController;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        playerController = player.GetComponent<PlayerController>();
    }

    // Update is called once per frame
    void Update()
    {
        transform.position = new Vector3(player.transform.position.x, player.transform.position.y + 1, player.transform.position.z);
    }

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Block")) { playerController.canJump = false; }
    }

    void OnCollisionExit(Collision collision)
    {
        if (collision.gameObject.CompareTag("Block")) { playerController.canJump = true; }
    }
}
