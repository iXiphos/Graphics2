using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationLerp : MonoBehaviour
{

    public Vector3[] curveWaypoint;
    public Vector3[] curveTangent;
    int curveSegmentIndex;
    float curveSegmentTime;
    public float curveSegmentDuration;

    // Start is called before the first frame update
    void Start()
    {
        curveSegmentIndex = 0;
    }

    // Update is called once per frame
    void Update()
    {
        Animate();
    }

    void Animate()
    {
        int i0, i1;
        i0 = curveSegmentIndex;
        i1 = (curveSegmentIndex + 1) % 2;

        float u = curveSegmentTime / curveSegmentDuration;

        float a = (1.0f + 2.0f * u) * (1.0f - u) * (1.0f - u) * (1.0f - u);
        float b = u * (1 - u) * (1 - u) * (1 - u);
        float c = u * u * (3 - 2 * u);
        float d = u * u * (u - 1);

        //a = a * 0.5f;
        Vector3 p0 = curveWaypoint[i0];
        p0 *= a;

        //b = b * -1.0f;
        Vector3 t0 = curveTangent[i0];
        t0 *= b;

        //c = c * 2.8f;
        Vector3 p1 = curveWaypoint[i1];
        p1 *= c;

        //d = d * -1.f;
        Vector3 t1 = curveTangent[i1];
        t1 *= d;



        Vector3 loc = p0;
        loc += p1;
        loc += t0;
        loc += t1;


        //a3real4Lerp(loc.v, demoMode->curveWaypoint[i0].v, demoMode->curveWaypoint[i1].v, u);

        gameObject.transform.position = loc;

        curveSegmentTime += Time.deltaTime;

        //when time excedes the duration we move to the next segment
        if (curveSegmentTime >= curveSegmentDuration)
        {
            curveSegmentTime -= curveSegmentDuration;
            curveSegmentIndex = i1;
        }
    }
}
