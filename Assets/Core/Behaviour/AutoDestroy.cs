﻿using UnityEngine;
using System.Collections;

namespace SmileAndLearn
{
	public class AutoDestroy : MonoBehaviour
	{

		public float time;
		// Use this for initialization
		void Start ()
		{
			Destroy(this.gameObject,time);
		}
	}
} 