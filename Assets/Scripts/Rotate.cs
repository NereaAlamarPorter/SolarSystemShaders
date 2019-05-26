using System.Collections;
using System.Collections.Generic;
using UnityEngine;


    public class Rotate : MonoBehaviour
    {
        [SerializeField] float speed_rot;

        void Update()
        {
                transform.RotateAround(transform.position, transform.up, speed_rot);
       
        }
    }
