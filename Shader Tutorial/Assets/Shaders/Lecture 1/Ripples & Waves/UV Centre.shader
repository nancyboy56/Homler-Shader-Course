Shader "Unlit/Uv Centre"
{

    // input data
    Properties 
    {
        
        _Colour1("Colour 1", Color) = (0,0,0,1)
        _Colour2("Colour 2", Color) = (1,1,1,1)
        /*_ColourStart("Colour Start", Range(0,1)) = 0.0
        _ColourEnd("Colour End", Range(0,1) ) = 1.0*/
        _YScale("Y Axis Cos Scale", Range(0,10)) = 5
        _xOffsetCo("Gradient Blend", Range(0,3)) = 0.6
        _TimeScale("Movement Speed", Range(-0.15,0.15)) = 0.1
        _WaveAmp("Wave Amplitude", Range(-1,5)) =0.1
    }

    SubShader
    {
        // when dealing with transparent you want to sent the render type to transparent
        //also set render queue to transparent
        // render type is mostly just for tagging like for post process effects
        // render queue is the actual order that things are going ot be drawn in
        Tags { 
            "RenderType"="Opaque"
        }
        
        //you can set a LOD level of an object and it will pick different subshaders
        LOD 100
        
        Pass
        {
            
            
            // depth buffer
           // Zwrite Off
            
            // default value is Lequal means read the buffer
           // ZTest LEqual means less than or equal to
            //ZTest Always means always draw
            //Ztest Gequal means greater than or equal too
            
            
            //Additive
           // Blend One One
            
            // multiply
            //Blend DstColor Zero
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            //bulit in functions
            #include "UnityCG.cginc"

            #define TAU 6.283185307179586476925287

            //define variables
            float4 _Colour1;
            float4 _Colour2;
            /*float _ColourStart;
            float _ColourEnd;*/
            float _YScale;
            
            float _xOffsetCo;
            float _TimeScale;
            float _FadeScale;
            float _Saturation;
            float _WaveAmp;
                            
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

               float waveY = cos((v.uv0.y + _Time.y * _TimeScale) * _YScale * TAU);
                float waveX = cos((v.uv0.x + _Time.y * _TimeScale) * _YScale * TAU);

                //using wave to modify the y coordinate of the vertex
                v.vertex.y = waveY * waveX * _WaveAmp;

                
                o.vertex = UnityObjectToClipPos(v.vertex);
                 o.normal = UnityObjectToWorldNormal(v.normals);

                //scaling in vertex shader bc its faster
               o.uv = v.uv0;
               // o.uv = (v.uv0 + _Offset) * _Scale;
                
                return o;
            }

            // Can give start and end points to lerps
            float InverseLerp( float start, float end, float i)
            {
                return (i-start)/(end-start);
            }
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
                //return float4(i.uv,0,1);
                //float xOffset = _xOffsetCo * cos(i.uv.x * TAU * _XOffsetScale);
                //float t = frac(i.uv.y);
                /*float waveY = _xOffsetCo * cos((i.uv.y + _Time.y * _TimeScale) * _YScale * TAU)+0.5;
                float waveX = _xOffsetCo * cos((i.uv.x + _Time.y * _TimeScale) * _YScale * TAU)+0.5;*/
              //  t *= 1-i.uv.y;
                //float4 colour = lerp(_Colour1, _Colour2, i.uv.y);
                
              return float4(i.uv * 2 -1,0,1);
                //return wave;
         
            }
            ENDCG
        }
    }
}
