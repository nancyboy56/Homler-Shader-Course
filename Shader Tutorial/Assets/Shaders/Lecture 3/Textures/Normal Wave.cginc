#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define USE_LIGHTING 
#define TAU 6.283185307179586476925287
sampler2D _Albedo;
sampler2D _Height;
float4 _Albedo_ST;
float _Gloss;
float4 _Colour;
sampler2D _Normals;
float _Strength;
float _TimeScale;
float _xOffsetCo;
float _YScale;
//float4 _Normals_ST;


struct MeshData
{
    //vertex position
    float4 vertex : POSITION;

    //usually have normals there
    float3 normal: NORMAL;

    //could not be COLOR but you can get the colour of the vertex
    float4 colour: COLOR;

    //tangents have be float4s!
    // xyz is the tangent direction
    // w is the tangent 
    // w is just in case we have flipped uvs
    float4 tangent: TANGENT;

    //uv coordinates
    float2 uv : TEXCOORD0;
    
    float4 uv1 : TEXCOORD1;
};

struct Interpolators
{
    //clip space postion of this vertex, between -1,1 for this particular position
    float4 vertex : SV_POSITION;

    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    //doesnt need to be float4
    float3 tangent : TEXCOORD2;
    float3 bitangent : TEXCOORD3;
    float3 world : TEXCOORD4;
    
    /*// for fog
    UNITY_FOG_COORDS(1)*/

    // this is a unity macro to handle light
    //since we ar using texcoords0,1,2 we give it 3 and 4
    LIGHTING_COORDS(5,6)
    
};


// vertex shader
Interpolators vert (MeshData v)
{
    Interpolators o;
    v.vertex.xyz += v.normal * _xOffsetCo * cos((v.uv.x + _Time.y * _TimeScale) * _YScale * TAU);
    o.vertex = UnityObjectToClipPos(v.vertex);
    
    o.uv = TRANSFORM_TEX(v.uv, _Albedo);
    o.normal=UnityObjectToWorldNormal(v.normal);
    
    o.tangent = UnityObjectToWorldDir(v.tangent.xyz);

    // tangent.w is multipled if we have flipped uvs
    //to make sure all scaling is handled correctly
    o.bitangent = cross(o.normal, o.tangent) * (v.tangent.w * unity_WorldTransformParams.w);
    //ingoring fog for now
   // UNITY_TRANSFER_FOG(o,o.vertex);
    o.world = mul(unity_ObjectToWorld, v.vertex);
    // this is about lighting information
    TRANSFER_VERTEX_TO_FRAGMENT(o);
    return o;
}

//fragement shader
float4 frag (Interpolators i) : SV_Target
{
    //return float4 (1,1,1,1);
    float3 albedo = tex2D(_Albedo, i.uv);

    float3 surface =  albedo * _Colour.rgb;
    float3 tangentNormal = float4(UnpackNormal(tex2D(_Normals, i.uv)), 0);
    tangentNormal = normalize(lerp(float3(0,0,1), tangentNormal, _Strength ));

    float3x3 mtxTangToWorld = {
        i.tangent.x, i.bitangent.x, i.normal.x,
        i.tangent.y, i.bitangent.y, i.normal.y,
        i.tangent.z, i.bitangent.z, i.normal.z,
    };

    // world space normal    
    float3 normal = mul(mtxTangToWorld, tangentNormal);
    
   
    // if defined then use lighting
    //instead of brackets
    #ifdef USE_LIGHTING
        // this defined its going to compile this code

        // need to normalize the normal between vetrecies bc at the moment they are just being lerped
        //float3 normal =normalize(i.normal);

        // direction of whatever light we have
        // but its not normalised
        float3  light = normalize(UnityWorldSpaceLightDir(i.world));

        // how light falls off the further u get aay from it
        float attenuation = LIGHT_ATTENUATION(i);
        float3 lambert = saturate(dot(normal, light));
        float3 diffuse = lambert * attenuation *_LightColor0.xyz;

        //specular light
        float3 view = normalize(_WorldSpaceCameraPos - i.world);
        //  float3 reflection = reflect(-light, normal);
        float3 halfVector = normalize(light + view);

        // Blinn Phong
        float3 specular = saturate(dot(halfVector, normal)) * (lambert >0);

        // this might be expensive to do in real time
        // might want to do it on the c# end
        float specularExponent = exp2(_Gloss * 6 ) + 2;
        // somtimes called the specular exponent
        // a bad estimation at energy consrvation
        specular = pow(specular, specularExponent) * _Gloss * attenuation;
        specular *= _LightColor0.xyz;
        return float4(diffuse * surface + specular, 1);
    #else
    // if not defined going to compile this code
        #ifdef IS_IN_BASE_PASS
            return surface;
        #else
            return 0;
        #endif
    #endif
    
}