using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PerlinMove : MonoBehaviour {
    Renderer rend;
    [SerializeField] float speedX, speedY;


	void Start () {
        rend = gameObject.GetComponent<Renderer>();
    }
	
	void Update () {
        rend.sharedMaterial.SetFloat("_X", rend.sharedMaterial.GetFloat("_X") + speedX);
        rend.sharedMaterial.SetFloat("_Y", rend.sharedMaterial.GetFloat("_Y") + speedY);

    }
}
