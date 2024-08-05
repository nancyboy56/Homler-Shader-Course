Shader "Unlit/Texture"
{

    // input data
    Properties 
    {
        // this is unity default texture. its 2D
        //there are 3D textures and cube maps
        //all work in diferent ways
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

            //sampler2D means 2D texture type
            sampler2D _MainTex;

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
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;

                // for fog
                UNITY_FOG_COORDS(1)
                
            };

            
            // vertex shader
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);

                //this is optional
                //this offset, scales with the texture
                o.uv = TRANSFORM_TEX(v.uv0, _MainTex);
                //can just do o.uv =v.uv but doesnt use the offset,scale
                //if you dont use the default offset and scale values doesnt matter can just pass through uvs

                //ingoring fog for now
                UNITY_TRANSFER_FOG(o,o.vertex);
                
                return o;
            }
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
                
                // sample the texture
                // input colour from texture
                //the space we are working in is from 0 to 1
                // this is also known as normalised corrdinates
                fixed4 col = tex2D(_MainTex, i.uv);

                
                // apply fog
                //ignoring fog
                // UNITY_APPLY_FOG(i.fogCoord, col);

                // output white
                return col;
            }
            ENDCG
        }
    }
}
