using System.Collections;
using System.Collections.Generic;   
using UnityEngine;


public enum SoundType
{
    MenuMusic,
    GameMusic,
    FrogJump,
    ObjectFall,
    Death,
    Win,
    Lose,
    ButtonClick
}

[RequireComponent(typeof(AudioSource))]
public class SoundManager : MonoBehaviour
{
    [SerializeField] private AudioClip[] soundList;
    public static SoundManager instance;
    private AudioSource audioSource;    

    private void Awake()
    {
        instance = this;
        audioSource = GetComponent<AudioSource>();
    }

    public static void PlaySound(SoundType sound, float volume = 1)
    {
        instance.audioSource.PlayOneShot(instance.soundList[(int)sound], volume);
    }

    public static void PlayLooping(SoundType sound, float volume = 1)
    {
        instance.audioSource.clip = instance.soundList[(int)sound];
        instance.audioSource.volume = volume;
        instance.audioSource.loop = true;
        instance.audioSource.Play();
    }
    public void PauseSound(bool _pausetrigger)
    {
        if (_pausetrigger)
        {
            audioSource.Pause(); 
        }
        else
        {
            audioSource.UnPause();
        }
    }

    public void StopSound()
    {
        audioSource.Stop();
    }
}
