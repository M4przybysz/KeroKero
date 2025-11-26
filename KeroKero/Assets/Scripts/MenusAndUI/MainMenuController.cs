using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class MainMenuController : MonoBehaviour
{
    [SerializeField] GameObject[] levelButtons;
    bool areLevelsUnlocked;
    [SerializeField] GameObject credits;


    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        LoadLevelButtons();
        areLevelsUnlocked = false;
        ShowOrHideCredits(false);
        SoundManager.PlayLooping(SoundType.MenuMusic, 0.2f);


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

    void LoadLevelButtons()
    {
        // Show or hide level buttons
        for (int i = 0; i < levelButtons.Length && i <= GameManager.Instance.LevelsCompleted; i++)
        {
            levelButtons[i].GetComponent<Button>().interactable = true;
        }
    }

    public void UnlockOrLockAllLevels() // true == unlock, false = lock
    {
        areLevelsUnlocked = !areLevelsUnlocked;

        // Show or hide level buttons
        for (int i = GameManager.Instance.LevelsCompleted + 1; i < levelButtons.Length; i++)
        {
            levelButtons[i].GetComponent<Button>().interactable = areLevelsUnlocked;
        }
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
