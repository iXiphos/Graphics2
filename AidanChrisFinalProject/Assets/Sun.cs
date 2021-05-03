using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sun : MonoBehaviour
{

    public Vector3[] curveWaypoint;

    int curveSegmentIndex;
    float curveSegmentTime;
    public float curveSegmentDuration;
    float curveSegmentParam = 0;


    public Transform lookTransform;
    public bool animate;

    // Start is called before the first frame update
    void Start()
    {
        curveSegmentIndex = 0;
    }

    // Update is called once per frame
    void Update()
    {
        if(animate)
            Animate();

        gameObject.transform.LookAt(lookTransform);
    }

    void Animate()
    {
        int waypointCount = curveWaypoint.Length;
        //adapted from project 4
        int i0, i1, i2, i3;
        i0 = curveSegmentIndex;
        i1 = (curveSegmentIndex + 1) % waypointCount;
        i2 = (curveSegmentIndex + 2) % waypointCount;
        i3 = (curveSegmentIndex + 3) % waypointCount;
       

        Vector3 loc = GetCatmullRomPosition(curveSegmentParam, curveWaypoint[i0],curveWaypoint[i1], curveWaypoint[i2], curveWaypoint[i3]);

        

        gameObject.transform.position = loc;

        curveSegmentTime += Time.deltaTime;             

        //when time excedes the duration we move to the next segment
        if (curveSegmentTime >= curveSegmentDuration)  
        {
            curveSegmentTime -= curveSegmentDuration;  
            curveSegmentIndex = i1;                    
        }
          curveSegmentParam = curveSegmentTime * (1 / curveSegmentDuration);

    }


    //found algorith here: https://www.habrador.com/tutorials/interpolation/1-catmull-rom-splines/
    Vector3 GetCatmullRomPosition(float t, Vector3 p0, Vector3 p1, Vector3 p2, Vector3 p3)
	{
		
		Vector3 a = 2f * p1;
		Vector3 b = p2 - p0;
		Vector3 c = 2f * p0 - 5f * p1 + 4f * p2 - p3;
		Vector3 d = -p0 + 3f * p1 - 3f * p2 + p3;

		
		Vector3 pos = 0.5f * (a + (b * t) + (c * t * t) + (d * t * t * t));

		return pos;
	}
}
