﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveCamera : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {

        transform.Translate(0, 0, Input.GetAxis("Vertical"));
        transform.Rotate(0, Input.GetAxis("Horizontal"), 0);

    }
}
