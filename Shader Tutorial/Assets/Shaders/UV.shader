Shader "Unlit/UV"
{

    // input data
    Properties 
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Colour("Colour", Color) = (1,1,1,1)
        
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
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float4 _Colour;
            
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
                
                // object space (model/mesh space) to world space
                //o.normal = UnityObjectToWorldNormal(v.normals);
                //pass through
                o.uv = v.uv0;
                return o;
            }
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
                // the uv coordinates depends on how the artist uv mapped the object
                // tradtionally like in mesh editing programs uv corrdinates are 2d
                return float4(i.uv, 0 ,1);
            }
            ENDCG
        }
    }
}
