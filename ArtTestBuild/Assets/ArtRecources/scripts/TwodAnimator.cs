using UnityEngine;
using System.Collections;

public class TwodAnimator : MonoBehaviour 
{

	public float secondsToWait;
	public Texture[] frames;
	public bool loop;
	
	public bool pause;
	public float pauseDelay;
	public Texture blankFrame;

	
	// Use this for initialization
	void Start () 
	{
		StartCoroutine(PlayAnimation());
	}
	IEnumerator PlayAnimation()
	{
		int currentFrame = 0;
		
		while(currentFrame < frames.Length)
		{
			renderer.material.mainTexture = frames[currentFrame];
			currentFrame++;
			yield return new WaitForSeconds(secondsToWait);
		}
		if(pause)
		{
			renderer.material.mainTexture = blankFrame;			
			yield return new WaitForSeconds(pauseDelay);
		}		
		currentFrame = 0;
		if(loop)
			StartCoroutine(PlayAnimation());
	}
}
