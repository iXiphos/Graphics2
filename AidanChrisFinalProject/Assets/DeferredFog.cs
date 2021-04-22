using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DeferredFog : MonoBehaviour
{

    public Shader deferredFog;
    [System.NonSerialized]
    public Material fogMaterial;

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(fogMaterial == null)
        {
            fogMaterial = new Material(deferredFog);
        }
        Graphics.Blit(source, destination);

    }
}
