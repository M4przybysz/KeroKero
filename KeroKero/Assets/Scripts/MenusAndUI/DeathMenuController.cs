using UnityEngine;
using UnityEngine.SceneManagement;

public class DeathMenuController : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        ShowOrHideMenu(false);
    }

    // Update is called once per frame
    void Update()
    {

    }

    void ShowOrHideMenu(bool showOrHide) // true - show, false - hide
    {
        for (int i = 0; i < transform.childCount; i++)
        {
            transform.GetChild(i).gameObject.SetActive(showOrHide);
        }
    }

    public void ShowDeathMenu()
    {
        // Lock and hide cursor
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.None;
        ShowOrHideMenu(true); // Show or hide pause menu
        Time.timeScale = 0; // Stop or resume gameplay;
        SoundManager.instance.StopSound();
    }
    
    public void RestartLevel(string levelName)
    {
        Time.timeScale = 1;
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
            
        SceneManager.LoadScene(levelName); // Restart current level
    }
    
    public void QuitToTitleScreen()
    {
        Time.timeScale = 1;
        SceneManager.LoadScene("TitleScreen"); // Quit to titlescreen
    }
}
