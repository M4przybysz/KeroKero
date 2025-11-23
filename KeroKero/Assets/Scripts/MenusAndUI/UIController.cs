using UnityEngine;

public class UIController : MonoBehaviour
{
    [SerializeField] Transform player;
    [SerializeField] RectTransform playerMarker, progressBar, holeHeightMarker;
    [SerializeField] float levelHeight;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        SoundManager.PlayLooping(SoundType.GameMusic, 0.2f);
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        UpdateUI();
    }

    void UpdateUI()
    {
        playerMarker.position = new Vector3(
            playerMarker.position.x,
            140 + (player.position.y - 1.15f) * holeHeightMarker.sizeDelta.y / levelHeight);

        progressBar.sizeDelta = new Vector2(
            progressBar.sizeDelta.x,
            (player.position.y - 1.15f) * holeHeightMarker.sizeDelta.y / levelHeight);
    }
}
