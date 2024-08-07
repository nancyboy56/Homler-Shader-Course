Shader "Unlit/Cos Time"
{

    // input data
    Properties 
    {
        
        _Colour1("Colour 1", Color) = (1,1,1,1)
        _Colour2("Colour 2", Color) = (1,1,1,1)
        /*_ColourStart("Colour Start", Range(0,1)) = 0.0
        _ColourEnd("Colour End", Range(0,1) ) = 1.0*/
        _Scale("Scale", Float) = 2.0
        _ZigScale("Zigzang Scale", Float) = 2.0
        _CosCo("Zigzang coeffceint", Float) = 0.1
        _TimeScale("Time Scale", Float) = 1
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

            #define TAU 6.283185307179586476925287

            //define variables
            float4 _Colour1;
            float4 _Colour2;
            /*float _ColourStart;
            float _ColourEnd;*/
            float _Scale;
            float _ZigScale;
            float _CosCo;
            float _TimeScale;
                            
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

                // this is time supplied by unity!
                // xyzw have different scales of time
                // _Time.xyzw
                // _Time.y is seconds
                 float xOffset = _CosCo * cos(i.uv.y*TAU*_ZigScale);
                //float t = frac(i.uv.y);
                float t = 0.5*cos((i.uv.x + xOffset+ (_Time.y*_TimeScale)) * _Scale* TAU)+0.5;

               
                
                float4 outColour = lerp(_Colour1, _Colour2, t);
                return outColour;

                
                
                //return t;
            }
            ENDCG
        }
    }
}
