using UnityEngine;
using UnityEngine.SceneManagement;

public class PauseMenuController : MonoBehaviour
{
    public bool isPauseOn {get; private set;}

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {

        isPauseOn = false;
        ShowOrHideMenu(false);
    }

    // Update is called once per frame
    void Update()
    {
        HandleInputs();
    }

    void HandleInputs()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            isPauseOn = !isPauseOn;

            // Lock and hide cursor
            Cursor.visible = isPauseOn;
            Cursor.lockState = Cursor.visible ? CursorLockMode.None : CursorLockMode.Locked;

            ShowOrHideMenu(isPauseOn); // Show or hide pause menu
            Time.timeScale = isPauseOn ? 0 : 1; // Stop or resume gameplay;
        }
    }
    
    void ShowOrHideMenu(bool showOrHide) // true - show, false - hide
    {
        SoundManager.instance.PauseSound(showOrHide);
        for(int i = 0; i < transform.childCount; i++)
        {
            transform.GetChild(i).gameObject.SetActive(showOrHide);
        }
    }

    public void ResumeGame()
    {
        isPauseOn = false;

        ShowOrHideMenu(false); // Hide pause menu
        Time.timeScale = 1; // Rsume game

        // Unlock and show cursor
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
    }

    public void RestartLevel(string levelName)
    {
        Time.timeScale = 1;
        SceneManager.LoadScene(levelName); // Restart current level
    }
    
    public void QuitToTitleScreen()
    {
        Time.timeScale = 1;
        SceneManager.LoadScene("TitleScreen"); // Quit to titlescreen
    }
}
