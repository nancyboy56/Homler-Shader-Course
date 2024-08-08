Shader "Unlit/Solution Pass"
{

    // input data
    Properties 
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss("Gloss Amount", Range (0,2) ) = 0.5
        _Colour("Surface Colour", Color) = (1,1 ,0,1)
        
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        //you can set a LOD level of an object and it will pick different subshaders
        LOD 100
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "MyLighting.cginc"
            ENDCG
        }
    }
}
