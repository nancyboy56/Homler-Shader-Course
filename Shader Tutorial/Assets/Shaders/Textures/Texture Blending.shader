Shader "Unlit/Blending"
{

    // input data
    Properties 
    {
        // "white" {} means what will be assigned if there is nothing assigned to it, the default
        // "white", "black", "gray", "bump" (for normal maps)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Pattern("Pattern Texture", 2D) = "white" {}
        _SecondTex("Blend Texture", 2D) = "white" {}
        
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
            #pragma multi_compile_fog
            
            //bulit in functions
            #include "UnityCG.cginc"

            //define variables

            //sampler2D means 2D texture type
            sampler2D _MainTex;
            sampler2D _Pattern;
            sampler2D _SecondTex;

            //this varaible is optional
            // This has Tiling and offset information is in
            float4 _MainTex_ST;
            
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
                float2 uv0 : TEXCOORD0;
                
                float4 uv1 : TEXCOORD1;
            };
            
            struct Interpolators
            {
                //clip space postion of this vertex, between -1,1 for this particular position
                float4 vertex : SV_POSITION;

                float2 uv : TEXCOORD0;
                float4 world : TEXCOORD1;
                float4 uv2 : TEXCOORD2;

                // for fog
                UNITY_FOG_COORDS(1)
                
            };

            
            // vertex shader
            Interpolators vert (MeshData v)
            {
                Interpolators o;

                //object to world
                //matrix multiplation is mul()
                //these two are the same equation
                // o.world = mul(unity_ObjectToWorld, v.vertex);
                // if the fourth componient of vertex is 0 transforms as vector or direction
                // if 4th componient is 1 transform as a poisition, taking offset into account
                o.world = mul(UNITY_MATRIX_M, float4 (v.vertex.xyz, 1) );
                o.vertex = UnityObjectToClipPos(v.vertex);

                //this is optional
                //this offset, scales with the texture
                o.uv = TRANSFORM_TEX(v.uv0, _MainTex);
                //can just do o.uv =v.uv but doesnt use the offset,scale
                //if you dont use the default offset and scale values doesnt matter can just pass through uvs
                
                //ingoring fog for now
               // UNITY_TRANSFER_FOG(o,o.vertex);
               // o.uv
                return o;
            }
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
                // we want to make the projection top down for the texture
                float2 topDownProjection =i.world.xz;

                //not using uv for corrdinates in texture but using worldspace
                float4 grass = tex2D(_MainTex, topDownProjection);
                float4 second = tex2D(_SecondTex, topDownProjection);
                float4 pattern = tex2D(_Pattern, i.uv);
               
                float4 colour = lerp( second, grass, pattern);
                return colour;
            }
            ENDCG
        }
    }
}
