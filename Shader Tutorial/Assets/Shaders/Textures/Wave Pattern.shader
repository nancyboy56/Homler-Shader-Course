Shader "Unlit/Wave Pattern"
{

    // input data
    Properties 
    {
        // "white" {} means what will be assigned if there is nothing assigned to it, the default
        // "white", "black", "gray", "bump" (for normal maps)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Pattern("Pattern Texture", 2D) = "white" {}
        _YScale("Wave Amount", Range(0,10)) = 5
        _xOffsetCo("Gradient Blend", Range(0,3)) = 0.6
        _TimeScale("Movement Speed", Range(-0.15,0.15)) = 0.1
        _WaveAmp("Wave Amplitude", Range(-1,5)) =0.1
        
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
             #define TAU 6.283185307179586476925287
            //sampler2D means 2D texture type
            sampler2D _MainTex;
            sampler2D _Pattern;
             float _YScale;
            
            float _xOffsetCo;
            float _TimeScale;
            float _FadeScale;
            float _Saturation;
            float _WaveAmp;

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

            float GetWave(float2 coords)
            {
                  //float2 uvCentre = coords * 2 -1;

                //float radialDistance = length(uvCentre);
                float wave = _xOffsetCo * cos((coords + _Time.y * _TimeScale) * _YScale * TAU)+0.5;
                wave *= coords;
                return wave;
            }
            
            // vertex shader
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.world = mul(UNITY_MATRIX_M, float4 (v.vertex.xyz, 1) );
                o.vertex = UnityObjectToClipPos(v.vertex);

            
                o.uv = TRANSFORM_TEX(v.uv0, _MainTex);
                
                return o;
            }
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
                // we want to make the projection top down for the texture
                float2 topDownProjection =i.world.xz;

                //not using uv for corrdinates in texture but using worldspace
                float4 grass = tex2D(_MainTex, topDownProjection);
                float4 pattern = tex2D(_Pattern, i.uv);
                float4 worldColours = float4(i.world.xyz, 1);

                
                return GetWave(pattern);
            }
            ENDCG
        }
    }
}
