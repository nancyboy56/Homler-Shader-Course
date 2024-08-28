Shader "Unlit/Normal Wave"
{

    // input data
    Properties 
    {
        _Albedo ("Texture Albedo", 2D) = "white" {} 
        [NoScaleOffset]_Normals("Normal", 2D) ="bump" {}
        
        // depends how you want to do it
        // if you want the started point to the top, bottom, or middle
        // gray is middle, centre so the height moves up and down from there
        [NoScaleOffset]_Height("Height", 2D) ="gray" {}
        _Gloss("Gloss Amount", Range (0,2) ) = 0.5
        _Colour("Surface Colour", Color) = (1,1 ,0,1)
        _Strength("Normal Intensity", Range(0,10)) =1
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        
        // base pass
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #define IS_IN_BASE_PASS
            #include "Height Map.cginc"
            ENDCG
        }

        // Add pass
        Pass
        {
            Tags {"LightMode" = "ForwardAdd" }
            
            Blend One One //scr + dst additive
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #include "Height Map.cginc"
            ENDCG
        }
    }
}
