Shader "Unlit/Front Cull"
{

    // input data
    Properties 
    {
        
        _Colour1("Colour 1", Color) = (0,0,0,1)
        _Colour2("Colour 2", Color) = (1,1,1,1)
        /*_ColourStart("Colour Start", Range(0,1)) = 0.0
        _ColourEnd("Colour End", Range(0,1) ) = 1.0*/
        _YScale("Y Axis Cos Scale", Float) = 2.0
        _XOffsetScale("X Offset Axis Cos Scale", Float) = 2.0
        _xOffsetCo("X Offset Cos Coeffceint", Float) = 0.1
        _TimeScale("Time Scale", Float) = 1
        _Saturation("Colour Saturation ", Float) = 1
        _FadeScale("Fade Scale", Range(0,1)) = 0.5
    }

    SubShader
    {
        // when dealing with transparent you want to sent the render type to transparent
        //also set render queue to transparent
        // render type is mostly just for tagging like for post process effects
        // render queue is the actual order that things are going ot be drawn in
        Tags { 
            "RenderType"="Transparent" 
            "Queue"="Transparent"
        }
        
        //you can set a LOD level of an object and it will pick different subshaders
        LOD 100
        
        Pass
        {
            // this is the default
            //back face culling
            //Cull Back
            
            Cull Front
            // depth buffer
            Zwrite Off
            //Additive
            Blend One One
            
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
            float _XOffsetScale;
            float _xOffsetCo;
            float _TimeScale;
            float _FadeScale;
            float _Saturation;
                            
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

                float xOffset = _xOffsetCo * cos(i.uv.x * TAU * _XOffsetScale);
                //float t = frac(i.uv.y);
                float t = 0.5 * cos((i.uv.y + xOffset + _Time.y * _TimeScale) * _YScale * TAU)+0.5;

                // this is a fade use the y uv for fading up and down and multiple it
                t *= _FadeScale * (1- i.uv.y) * _Saturation;
                t =saturate(t);
                float4 outColour = lerp(_Colour1, _Colour2, t);
                
                return outColour;

                
                
                //return t;
            }
            ENDCG
        }
    }
}
