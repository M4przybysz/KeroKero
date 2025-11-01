using UnityEngine;
using UnityEngine.SceneManagement;


#if UNITY_EDITOR
using UnityEditor;
#endif

public class MainMenuController : MonoBehaviour
{
    [SerializeField] GameObject credits;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        ShowOrHideCredits(false);

        // Unlock and show cursor
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.None;
    }

    public void PlayLevel(string levelName)
    {
        // Lock and hide cursor
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;

        SceneManager.LoadScene(levelName); // Load level
    }

    public void ShowOrHideCredits(bool showOrHide) // true == show, false == hide
    {
        credits.SetActive(showOrHide);
    }

    public void QuitGame()
    {
#if UNITY_EDITOR
        EditorApplication.ExitPlaymode();
#else
        Application.Quit();
#endif
    }
}
