Shader "Unlit/IBL"
{

    // input data
    Properties 
    {
        _Albedo ("Texture Albedo", 2D) = "white" {} 
        [NoScaleOffset]_Normals("Normal", 2D) ="bump" {}
        [NoScaleOffset]_Height("Height", 2D) ="gray" {}
        _DiffuseIBL ("Skybox IBL", 2D) = "black" {}
        _Gloss("Gloss Amount", Range (0,2) ) = 0.5
        _Colour("Surface Colour", Color) = (1,1 ,0,1)
        _AmbientColour("Ambient Colour", Color) = (0,0 ,0,0)
        _Strength("Normal Intensity", Range(0,10)) =1
       _TimeScale("Time", Float) =0.0
        _HeightStrength("Height Strength", Range(0,1)) =0.1
        
       
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
            #include "IBL.cginc"
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
            #include "IBL.cginc"
            ENDCG
        }
    }
}