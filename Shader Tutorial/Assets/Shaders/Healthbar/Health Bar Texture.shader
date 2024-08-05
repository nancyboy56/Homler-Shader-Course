Shader "Unlit/Health Texture"
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
        _Flash("Flash", Float) =5
        }
        
    
    SubShader
    {
       
        Tags { "RenderType"="Transparent" 
            "Queue"="Transparent" }
        
        //you can set a LOD level of an object and it will pick different subshaders
        LOD 100
        
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM

     
            #pragma vertex vert
            #pragma fragment frag
            
            // make fog work
            #pragma multi_compile_fog
            
            //bulit in functions
            #include "UnityCG.cginc"

            //define variables
            #define TAU 6.283185307179586476925287
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _StartColour;
            float4 _EndColour;
            float _Health;
            float _Start;
            float _End;
            float _Flash;
            
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
            float4 Remap(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
            {
                return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }
            
            // vertex shader
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.normal = UnityObjectToWorldNormal(v.normals);
                
                o.uv = TRANSFORM_TEX(v.uv0, _MainTex);

                //ingoring fog for now
                UNITY_TRANSFER_FOG(o,o.vertex);
               // o.uv = v.uv0; 
               // o.uv = v.uv0; 
                return o;
            }
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
                
                // sample the texture
                // ignoring textures
                float4 bar = tex2D(_MainTex, i.uv);

                
                // apply fog
                //ignoring fog
                // UNITY_APPLY_FOG(i.fogCoord, col);

                // output white
                //float t = InverseLerp(_Start, _End, _Health);
                // float4 colour = float4(1,1,1,0);
                 float4 colour = bar * (i.uv.x < _Health);
                 //float t = 0.5 * cos((i.uv.y +  + _Time.y * 0.5) * 5 * TAU)+0.5;
                float wave = 0.5* cos(_Time.y *_Flash)+0.5;
                
                 //float pluse = InverseLerp(1,0,);
                
                //Remap(i.uv.x, _Start, )
                //clamp()
                //clamp()
                float alpha = colour.a * (_Health >_Start ) + wave * (_Health<_Start && colour.a == 1);
                alpha = clamp(alpha, 0,1);
                colour =float4(colour.rgb, alpha);
                return colour;
            }
            ENDCG
        }
    }
}
