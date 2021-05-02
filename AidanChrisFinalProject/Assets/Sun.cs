using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sun : MonoBehaviour
{

    public Vector3[] curveWaypoint;

    int curveSegmentIndex;
    float curveSegmentTime;
    public float curveSegmentDuration;


    public Transform lookTransform;

    // Start is called before the first frame update
    void Start()
    {
        curveSegmentIndex = 0;
    }

    // Update is called once per frame
    void Update()
    {
        Animate();

        gameObject.transform.LookAt(lookTransform);
    }

    void Animate()
    {
        int i0, i1, i2, i3;
        i0 = curveSegmentIndex;
        i1 = (curveSegmentIndex + 1) % 4;
        i2 = (curveSegmentIndex + 2) % 4;
        i3 = (curveSegmentIndex + 3) % 4;
        float u = curveSegmentTime / curveSegmentDuration;

        Vector3 loc = GetCatmullRomPosition(u, curveWaypoint[i0],curveWaypoint[i1], curveWaypoint[i2], curveWaypoint[i3]);

        

        gameObject.transform.position = loc;

        curveSegmentTime += Time.deltaTime;

        //when time excedes the duration we move to the next segment
        if (curveSegmentTime >= curveSegmentDuration)
        {
            curveSegmentTime -= curveSegmentDuration;
            curveSegmentIndex = i1;
        }
    }

    Vector3 GetCatmullRomPosition(float t, Vector3 p0, Vector3 p1, Vector3 p2, Vector3 p3)
	{
		//The coefficients of the cubic polynomial (except the 0.5f * which I added later for performance)
		Vector3 a = 2f * p1;
		Vector3 b = p2 - p0;
		Vector3 c = 2f * p0 - 5f * p1 + 4f * p2 - p3;
		Vector3 d = -p0 + 3f * p1 - 3f * p2 + p3;

		//The cubic polynomial: a + b * t + c * t^2 + d * t^3
		Vector3 pos = 0.5f * (a + (b * t) + (c * t * t) + (d * t * t * t));

		return pos;
	}
}
