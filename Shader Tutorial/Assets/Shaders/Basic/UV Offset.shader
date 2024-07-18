Shader "Unlit/UV Offset"
{

    // input data
    Properties 
    {
        
        _Colour("Colour", Color) = (1,1,1,1)
        _Scale("UV Scale", Float) = 1.0
        _Offset("UV Offset", Float) = 0
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
            
            //bulit in functions
            #include "UnityCG.cginc"

            //define variables
            float4 _Colour;
            float _Scale;
            float _Offset;
            
            //automaticaally filled out by unity
            struct MeshData
            {
                //vertex position
                float4 vertex : POSITION;

                //usually have normals there
                float3 normals: NORMAL;

                //could not be COLOR but you can get the colour of the vertex
                float4 colour: COLOR;

                //tangents have be float4s!
                float4 tangent: TANGENT;

                //uv coordinates
                float4 uv0 : TEXCOORD0;
            };
            
            struct Interpolators
            {
                //clip space postion of this vertex, between -1,1 for this particular position
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

     
            // vertex shader
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);

                //scaling in vertex shader bc its faster
                o.uv = (v.uv0 + _Offset) * _Scale;
                
                return o;
            }
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
                return float4(i.uv, 0 ,1);
            }
            ENDCG
        }
    }
}
