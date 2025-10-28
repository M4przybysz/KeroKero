using UnityEngine;
using UnityEngine.SceneManagement;


#if UNITY_EDITOR
using UnityEditor;
#endif

public class MainMenuController : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.None;
    }

    public void PlayLevel1() { SceneManager.LoadScene("Level1"); }

    public void PlayLevel2() { SceneManager.LoadScene("Level2"); }

    public void PlayLevel3() { SceneManager.LoadScene("Level3"); }
    
    public void PlayEndlessMode() { SceneManager.LoadScene("EndlessMode"); }

    public void QuitGame()
    {
#if UNITY_EDITOR
        EditorApplication.ExitPlaymode();
#else
        Application.Quit();
#endif
    }
}
