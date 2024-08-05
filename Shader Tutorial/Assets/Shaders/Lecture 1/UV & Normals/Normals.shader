Shader "Unlit/Normals"
{

    // input data
    Properties 
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Colour("Colour", Color) = (1,1,1,1)
        
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

            //define variables
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float4 _Colour;
            
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
            };

            
            // vertex shader
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);

                // just pass data through the vertex shader
                //very common to do
                o.normal = v.normals; 
                return o;
            }
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
                //sometimes outputs negative values even tho you cant have negative colours
                // shader in the vertex and fragement shaders are desgined to never crash
                // if it complies it will output something
                // downsize you can divide by zero, get nan propagation throughout your rendering
                // hard to crash shaders
                // can have negative colour out puts, colours above one etc
                // it will show something
                // possible to render to a texture and render too a frame buffer
                // can render to a floating point texture if you want to

                // when we rotate the object in unity the normals dont corrspond to world space but local space
                    // sometimes called mesh space or model space
                return float4(i.normal,1);
            }
            ENDCG
        }
    }
}
