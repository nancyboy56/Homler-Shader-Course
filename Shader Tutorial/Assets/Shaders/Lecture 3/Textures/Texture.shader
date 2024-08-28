Shader "Unlit/Texture Light"
{

    // input data
    Properties 
    {
        _Albedo ("Texture Albedo", 2D) = "white" {}
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
            #include "Texture.cginc"
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
            #include "Texture.cginc"
            ENDCG
        }
    }
}
