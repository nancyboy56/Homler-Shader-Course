Shader "Unlit/Fresnel Cos"
{

    // input data
    Properties 
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss("Gloss Amount", Range (0,2) ) = 0.5
        _Colour("Surface Colour", Color) = (1,1 ,0,1)
        _TimeScale("Time Scale", Range (0,5)) =2
        
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
            float _Gloss;
            float4 _Colour;
            float _TimeScale;
            
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
                // neew to normalize the normal between vetrecies bc at the moment they are just being lerped
                float3 normal =normalize(i.normal);
                float3  light = _WorldSpaceLightPos0.xyz;
                float3 lambert = saturate(dot(normal, light));
                float3 diffuse = lambert *_LightColor0.xyz;
                
                //specular light
                float3 view = normalize(_WorldSpaceCameraPos - i.world);
                //  float3 reflection = reflect(-light, normal);
                float3 halfVector = normalize(light + view);

                // Blinn Phong
                float3 specular = saturate(dot(halfVector, normal)) * (lambert >0);

                // this might be expensive to do in real time
                // might want to do it on the c# end
                float specularExponent = exp2(_Gloss * 6 ) + 2;
                // somtimes called the specular exponent
                // a bad estimation at energy consrvation
                specular = pow(specular, specularExponent) * _Gloss;
                specular *= _LightColor0.xyz;

                float fresnel = (1- dot(view, normal )) * (cos(_Time.y*_TimeScale) *0.5 +0.5);
                //return fresnel;
                
                return float4(diffuse * _Colour + specular +fresnel, 1);
            }
            ENDCG
        }
    }
}
