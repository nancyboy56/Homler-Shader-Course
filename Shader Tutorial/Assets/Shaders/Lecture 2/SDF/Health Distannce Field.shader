Shader "Unlit/Health Distance Field"
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
        _Scale("Rounded Edge Scale", Range(1,15))=10
        }
    
    SubShader
    {
        Tags { 
            "RenderType"="Transparent" 
            "Queue"="Transparent" }
        
        //you can set a LOD level of an object and it will pick different subshaders
        LOD 100
        
        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            
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
            float _Scale;
            
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
                
                float2 coords = float2(i.uv.x*_Scale, i.uv.y);

                float2 lineCoords = float2( clamp(coords.x, 0.5,_Scale-0.5),0.5);
                float sdf = distance(coords, lineCoords);
                return float4(sdf.xxx,1);
                
                // this was my new solution, also freya's solution
                float3 colour = tex2D(_MainTex, float2 (_Health, i.uv.y));
                float mask = _Health> i.uv.x;
                
                if(_Health < 0.2)
                {
                    float flash = cos(_Time.y *4)* 0.5 + 1;
                    colour *= flash;
                }
               
                return float4(colour* mask, 1);
            }
            ENDCG
        }
    }
}
