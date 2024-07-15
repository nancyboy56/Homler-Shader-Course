Shader "Unlit/ShaderBasicNotes"
{

    // input data
    //exepect for mesh and lightinng and the stuff unity automaticaly supplies
    Properties 
    {
        _MainTex ("Texture", 2D) = "white" {}

        // _ValueTemp is the internal variable, Value Temp is what you see in the editor, type, default value
        _ValueTemp("Value Temp", Float) =1.0
    }

    // can have multiple subshaders 
    // normally only one 
    //for example for different performance types can have multiple
    
    SubShader
    {
        //Tags rendertype, queue (before or after another shader)
        // all that is set in subshader
        //more render pipline related 
        // these are subsahder tags
        Tags { "RenderType"="Opaque" }


        //you can set a LOD level of an object and it will pick different subshaders
        //depending on what you set LOD too
        //Fredya doesnt uses it, she just deletes it
        // LOD = level of detail
        LOD 100

        //pass has the rendering stuff
        //blending mode, stencil properties
        //graphics related
        Pass
        {
            //sometimes can have other tags in the pass

            // anything inside of the CGPROGRAM and ENDCG is shader code
            // unity is practially HLSL but they have there own version called CG
            // outside of CGPROGRAM is shaderlab, wrapper for unity shaders
            
            CGPROGRAM

            //way of telling the complier what function the vertex shader is in
            //and what function the fargement shader is in
            #pragma vertex vert
            #pragma fragment frag
            
            //if you dont need foog you can delete it
            // make fog work
            #pragma multi_compile_fog

            //takes a file and pastes code right there
            //contains a lot of unity specific things
            //bulit in functions, very useful
            //normally always have it there
            //can also have your own things included eg maths library
            #include "UnityCG.cginc"

            //define variables
            //sometimes called uniforms
            //if you have a propoerty you need a variable to go along with it
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            //need a value always to go along with the property
            //automaticaly gets the values from the property 
            float _ValueTemp;


            //normally called appdata but it isnt a very good name for the struct
            //renamed to meshdata
            //per vertex mesh data

            //automaticaally filled out by unity
            struct MeshData
            {
                //even though the float4 all isnt used in the position,
                //most data from the mersh comes in as a float4, all in clusters of 4
                //sometimes uv have float4 data when your not using actually uv in the uv channels

                //vertex position
                //vertex and uv are varible names, so you can all them whatever you want!
                //the colon is called a semantic, tells the complier we want position data
                float4 vertex : POSITION;

                //usually have normals there
                float3 normals: NORMAL;

                //could not be COLOUR but you can get the colour of the vertex
                float4 colour: COLOR;
                
                //tangents have be float4s!
                //4th coordinate has sign information
                float4 tangent: TANGENT;

                //uv coordinates
                //very general, you can use them for almost anything
                //often they are used for mapping textures to objects
                //TEXCOORD0 refers to UV channel 0
                float2 uv0 : TEXCOORD0;

                //uvs can be whatver you define them to be
                //for example uv0 diffuse/normal map textures and uv1 lightmap corrdinates 
                //you can keep going like this and get the other uv corrdinate
                //you can make them float4s
                float4 uv1 : TEXCOORD1;
            };


            // v2f is the default name for the data that gets passed from
            //the vertex shader to the fragment shader
            // fredya likes naming it something other than vf2
            //like FragInput, Interpolators

            //renamed Interpolators
            struct Interpolators
            {

                // colon is sematics
                //clip space postion of this vertex, between -1,1 for this particular position
                //always have to set this one!
                //but not the rest
                float4 vertex : SV_POSITION;

                //this can be any date you want it to be
                // in this case TEXCOORD0 does not refer to uv channels!

                float2 uv : TEXCOORD0;

                // you can write a bunch of textcoords in here 
                //what they mean is whatever you want them to have
                //as long as they data types you have
                //max is float4
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;

                // ignoring fog
                UNITY_FOG_COORDS(1)
                
            };

            
            // vertex shader
            Interpolators vert (MeshData v)
            {
                // o is often used to mean output
                Interpolators o;

                // unity has a bulid in function for unity objects to clip position
                // this is multiplying by the mpv matrix, model view projection matrix
                // converts local space to clip space
                //and that become the vertex part of interpolator
                o.vertex = UnityObjectToClipPos(v.vertex);

                //we are ignoring textures for now
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //ingoring fog for now
                UNITY_TRANSFER_FOG(o,o.vertex);

                // all it returns is the interpolators
                return o;
            }

            //varible types for shaders

            // float, half, fixed (as explained below)
            //float4 -> half4 -> fixed4
            //float4x4 -> half4x4 (C#: Matrix4x4)
            //bool = 0 or 1
                // can multiple by bool, under the hood just
                // bool2, bool3, etc all possible
            // int, int2 etc
                // tho it often can just get converted to floating point value
            // shader supports a lot of vectors
            

            // in unity c# float4 = Vector4 
            // float (32 bit float)
            // half (16 bit float)
            // fixed (12 bit float, tho it depends on then platform, in general just lower presicion)
                // unity says its 11 bits in opengl, what a strange number
            // fixed is only useful in the -1 to 1 range, or else the presicion is not great
            // half is pretty good for most things
            // very rarely need to use float,
                // works well for world space
            // now some pc platforms dont support half or fixed, only support float
            // half and fixed is used to get more optermisation in shaders
            // if doing stuff on mobile than half presicion is going to be important
            // float4 -> half4 -> fixed4
            //float4x4 -> half4x4 (C#: Matrix4x4)
            // using less precision uses less memory and is often faster
                // for example in gpu instancing in unity

            //can run into werid bugs and errors fromo using low precision
            //really hard to debug
            // so only optermise if you need to
            // you dont have to optermising everything for stuff that doesnt matter
            //use float everywhere until you have to optermise
            //or unless you know what your doing
            
            
            // the return value was a fixed4, changed to a float4
            // : SV_Target, is a semantic
            // this fragement shader should output to the frame buffer
            // this is the case most of the time
            // if you are doing defered rendering you can write to multiple targets
            
            //fragement shader
            float4 frag (Interpolators i) : SV_Target
            {
                
                // sample the texture
                // ignoring textures
                // fixed4 col = tex2D(_MainTex, i.uv);

                
                // apply fog
                //ignoring fog
                // UNITY_APPLY_FOG(i.fogCoord, col);

                //0 1 2 3 
                //R G B A
                //X Y Z W
                //this is often what is corresponds to

                // often alpha channel is transpency, but you can also use it for other information
                // like you usually use the w component just to pass some data, not because you have a 4d point

                // shaders make no distinction between colours and vectors
                // they are all float4, float3 etc
                // no colour type or vector type, all the same

                //swizzling
                float4 myValue;
                float2 othervalue = myValue.xy;

                // can replace xy for rg (red and green)
                float2 othervalue2 = myValue.rg;

                // can even fliup rg to gr and it still understands
                float2 othervalue3 = myValue.gr;

                //the hello world of shaders
                //outputting red
                return float4(1,0,0,1);
            }
            ENDCG
        }
    }
}
