Shader "Unlit/Clip Solution"
{

    // input data
    Properties 
    {
        _MainTex ("Texture", 2D) = "black" {}
        _StartColour("Health Colour", Color) = (1,0,0,1)
        _EndColour("Health Colour End", Color) =  (0,1,0,1)
        _Health("Health Percentage", Range(0,1)) = 0.1 
        _Start("Start Point", Range(0,1)) = 0.2
        _End("End Point", Range(0,1)) = 0.8
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
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _StartColour;
            float4 _EndColour;
            float _Health;
            float _Start;
            float _End;
            
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
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;

                // for fog
                UNITY_FOG_COORDS(1)
                
            };

             float InverseLerp( float start, float end, float i)
            {
                return (i-start)/(end-start);
            }
            
            // vertex shader
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.normal = UnityObjectToWorldNormal(v.normals);
                
                //o.uv = TRANSFORM_TEX(v.uv0, _MainTex);

                //ingoring fog for now
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.uv = v.uv0; 
               // o.uv = v.uv0; 
                return o;
            }
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
                float healthMask = _Health> i.uv.x;
                
                //doesnt render pixel if less than 0
                // with clip you can kinda make transparent shaders without all the sorting issues
                //you get with alpha bending
                //only 1 bit transparenty
                //can use dithered fading to look like actual semi transparenty
                //want to clip as early as possible
                clip(healthMask -0.0001);
                
                //mask

                //makes it into chunks
                //float healthMask = _Health> floor(i.uv.x*8)/8;

                //saturate is the clamp function
                float tHealth = saturate(InverseLerp(_Start, _End, _Health));
                float3 healthColour = lerp(_StartColour, _EndColour, tHealth);
                float3 background = float3(0,0,0);

                //Mathf.Lerp() is clamped
                //lerp() is unclamped
                float3 outColour = lerp(background, healthColour, healthMask);
                
                return float4(outColour, 1) ;
            }
            ENDCG
        }
    }
}
