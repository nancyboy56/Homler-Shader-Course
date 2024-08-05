Shader "Unlit/Swizzling"
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
            
            //bulit in functions
            #include "UnityCG.cginc"

            //define variables
            sampler2D _MainTex;
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
                
  
            };
            
            struct Interpolators
            {
                //clip space postion of this vertex, between -1,1 for this particular position
                float4 vertex : SV_POSITION;

                float2 uv : TEXCOORD0;
          

                // for fog
                UNITY_FOG_COORDS(1)
            };
            
            // vertex shader
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //ingoring fog for now
                UNITY_TRANSFER_FOG(o,o.vertex);
                
                return o;
            }
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
                //swizzling
                float4 myValue;
                float2 othervalue = myValue.xy;

                // can replace xy for rg (red and green)
                float2 othervalue2 = myValue.rg;

                // can even fliup rg to gr and it still understands
                float2 othervalue3 = myValue.gr;

                //possibles are endless!
                float4 othervalue4 = myValue.xxxx;

                // you cant write myValue.rrr1 to automanticaly put 1 in the alpha channel
                // doesnt work!
                

                // output white
                return float4(0,0,0,1);
            }
            ENDCG
        }
    }
}
