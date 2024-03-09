Shader "Unlit/Normals World Space"
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

            //if you want to optermise think about how many pixels you have vs how many vertecies you have
            //usually you have more pixels
            //so its quiter to do things in the vertex shader bc it has less things to calculate
            //and do as little as possible in the fragment shader
            
            // vertex shader
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);

                
                
                
                // object space (model/mesh space) to world space
                // has normal bc this function does some extra stuff depending on how you set up unity
                    // like if you do non uniform scaling of your object
                o.normal = UnityObjectToWorldNormal(v.normals);

                // if you wanted to do UnityObjectToWorldNormal by hand
                //unity_WorldToObject is 4x4 but if your doing a direction you can discard the 4th column
                // the reason why its unity_WorldToObject not the other way around is
                // //bc of how the matrix multiunity_WorldToObjectle is set up
                
                // o.normal = mul(v.normals, (float3x3) unity_WorldToObject);

                //this is really what it means
                //this is more readable as we are going from object to world
                //o.normal = mul((float3x3) unity_ObjectToWorld, v.normals);

                // also the same thing
                //UNITY_MATRIX_M is the MPV matrix
                //o.normal = mul((float3x3) UNITY_MATRIX_M, v.normals)

                //unity recommend using their names bc thats how they change them to different platforms
                //and they deal with edge cases
                //and can port to other systems better
                
                return o;
            }
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
               // normals colour

                // works the same as in the vertex shader
                //this is just in the fragement shader
                // return float4(UnityObjectToWorldNormal(i.normals),1);
                
                return float4(i.normal,1);
            }
            ENDCG
        }
    }
}
