using UnityEngine;
using UnityEngine.SceneManagement;

public class WinMenuController : MonoBehaviour
{
    [SerializeField] int unlockLevels;

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

    public void ShowWinMenu()
    {
        // Lock and hide cursor
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.None;

        ShowOrHideMenu(true); // Show or hide pause menu
        Time.timeScale = 0; // Stop or resume gameplay;

        // Update completed levels
        if (GameManager.Instance.LevelsCompleted < unlockLevels)
        {
            GameManager.Instance.LevelsCompleted = unlockLevels;
            GameManager.Instance.SavePlayerData();
        }
    }

    public void LoadLevel(string levelName)
    {
        Time.timeScale = 1;
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
            
        SceneManager.LoadScene(levelName); // Load level
    }
    
    public void QuitToTitleScreen()
    {
        Time.timeScale = 1;
        SceneManager.LoadScene("TitleScreen"); // Quit to titlescreen
    }
}
