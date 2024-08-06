Shader "Unlit/Phong Light"
{

    // input data
    Properties 
    {
        _MainTex ("Texture", 2D) = "white" {}
        
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
            
            #include "UnityCG.cginc"
            
            //need to include unity lighting files
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            //define variables
            #define TAU 6.283185307179586476925287
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            //automaticaally filled out by unity
            struct MeshData
            {
                //vertex position
                float4 vertex : POSITION;

                //usually have normals there
                float3 normal: NORMAL;

                //could not be COLOR but you can get the colour of the vertex
                float4 colour: COLOR;

                //tangents have be float4s!
                float4 tangent: TANGENT;

                //uv coordinates
                float2 uv : TEXCOORD0;
                
                float4 uv1 : TEXCOORD1;
            };
            
            struct Interpolators
            {
                //clip space postion of this vertex, between -1,1 for this particular position
                float4 vertex : SV_POSITION;

                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 world : TEXCOORD2;

                // for fog
                UNITY_FOG_COORDS(1)
                
            };

            
            // vertex shader
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal=UnityObjectToWorldNormal(v.normal);
                o.world = mul(unity_ObjectToWorld, v.vertex);
                //ingoring fog for now
                UNITY_TRANSFER_FOG(o,o.vertex);
                
                return o;
            }
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
                float3 normal =i.normal;
                float3  light = _WorldSpaceLightPos0.xyz;
                float3 diffuse = saturate(dot(normal, light)) *_LightColor0.xyz;
                
                //specular light
                float3 view = normalize(_WorldSpaceCameraPos - i.world);
                float3 reflection = reflect(-light, normal);
                float3 specular = saturate(dot(view, reflection));
                
                return float4(specular, 1);
            }
            ENDCG
        }
    }
}
