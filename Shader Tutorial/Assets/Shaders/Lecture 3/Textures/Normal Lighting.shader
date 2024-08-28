Shader "Unlit/Normal Lighting"
{

    // input data
    Properties 
    {
        _Albedo ("Texture Albedo", 2D) = "white" {}
        // white isnt a valid colour in normal map
        // if you want it to look like its flat you need to set value to bump
        // short for bump map
        // bump map is an outdated turn from normal maps
        [NoScaleOffset]_Normals("Normal", 2D) ="bump" {}
        _Gloss("Gloss Amount", Range (0,2) ) = 0.5
        _Colour("Surface Colour", Color) = (1,1 ,0,1)
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
            #include "Normal Lighting.cginc"
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
            #include "Normal Lighting.cginc"
            ENDCG
        }
    }
}
