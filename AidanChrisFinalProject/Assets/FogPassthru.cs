using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogPassthru : MonoBehaviour
{
    // Start is called before the first frame update
    public Transform sun;
    public Terrain terrain;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Vector4 vec = new Vector4(sun.position.x, sun.position.y, sun.position.z,0);
        terrain.GetComponent<Terrain>().materialTemplate.SetVector("_SunPos", vec);
        
    }
}
