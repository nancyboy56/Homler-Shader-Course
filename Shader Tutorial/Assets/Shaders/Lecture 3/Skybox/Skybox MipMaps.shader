Shader "Unlit/Skybox Mips"
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
           // #pragma multi_compile_fog
            
            //bulit in functions
            #include "UnityCG.cginc"

            //define variables
            #define TAU 6.283185307179586476925287
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

                //view direction
                float3 view : TEXCOORD0;
                
                
            };
            
            struct Interpolators
            {
                //clip space postion of this vertex, between -1,1 for this particular position
                float4 vertex : SV_POSITION;

                //view direction
                float3 view : TEXCOORD0;
                

                // for fog
                //UNITY_FOG_COORDS(1)
                
            };

            
            // vertex shader
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.view = v.view;

                //ingoring fog for now
                //UNITY_TRANSFER_FOG(o,o.vertex);
                
                return o;
            }

            float2 DirectionToRectilinear(float3 direction)
            {
                //0 to 1
                float x =atan2(direction.z, direction.x) /TAU + 0.5;
                float y = direction.y * 0.5 + 0.5;
                return float2(x,y);
            }
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
                //a bit of a hack lol
                float3 skybox = tex2Dlod(_MainTex, float4(DirectionToRectilinear(i.view),0,0));
                return float4(skybox,1);
                //ignoring fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                
                
            }
            ENDCG
        }
    }
}
