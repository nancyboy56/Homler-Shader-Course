Shader "Unlit/Skybox Colour"
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
            
            // make fog work
           // #pragma multi_compile_fog
            
            //bulit in functions
            #include "UnityCG.cginc"

            //define variables
            #define TAU 6.283185307179586476925287
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
                float3 uv : TEXCOORD0;
                
                float4 uv1 : TEXCOORD1;
            };
            
            struct Interpolators
            {
                //clip space postion of this vertex, between -1,1 for this particular position
                float4 vertex : SV_POSITION;

                float3 uv : TEXCOORD0;
                

                // for fog
                //UNITY_FOG_COORDS(1)
                
            };

            
            // vertex shader
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv = v.uv;

                //ingoring fog for now
                //UNITY_TRANSFER_FOG(o,o.vertex);
                
                return o;
            }
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
                float4 colour = tex2D(_MainTex, i.uv);
                return _Colour;
                //ignoring fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                
                return colour;
            }
            ENDCG
        }
    }
}