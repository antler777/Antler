using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player_Pos : MonoBehaviour
{
    public Vector3 playerPos;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        playerPos = transform.position;
        Shader.SetGlobalVector("_PlayerPos" , playerPos);
        Debug.Log(playerPos);
    }
}
