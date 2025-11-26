using System;
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
            Mathf.Clamp(140 + (player.position.y - 1.15f) * holeHeightMarker.sizeDelta.y / levelHeight, 140f, 140 + holeHeightMarker.sizeDelta.y));

        progressBar.sizeDelta = new Vector2(
            progressBar.sizeDelta.x,
            Math.Clamp((player.position.y - 1.15f) * holeHeightMarker.sizeDelta.y / levelHeight, 0f, holeHeightMarker.sizeDelta.y));
    }
}
