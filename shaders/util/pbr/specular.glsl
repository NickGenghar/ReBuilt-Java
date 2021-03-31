#define ENABLE_SPECULAR

uniform sampler2D specular, depthtex1;
uniform mat4 gbufferProjectionInverse;
uniform vec3 shadowLightPosition, upPosition;
uniform float pi;

vec3 fresnelSchlick(float cosTheta, vec3 f0) {
    return f0 + (1.0 - f0) * pow(max(1.0 - cosTheta, 0.0), 5.0);
}

float DistributionGGX(vec3 N, vec3 H, float roughness) {
    float a      = roughness*roughness;
    float a2     = a*a;
    float NdotH  = max(dot(N, H), 0.0);
    float NdotH2 = NdotH*NdotH;
	
    float num   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = pi * denom * denom;
	
    return num / denom;
}

float GeometrySchlickGGX(float NdotV, float roughness) {
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float num   = NdotV;
    float denom = NdotV * (1.0 - k) + k;
	
    return num / denom;
}

float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness) {
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2  = GeometrySchlickGGX(NdotV, roughness);
    float ggx1  = GeometrySchlickGGX(NdotL, roughness);
	
    return ggx1 * ggx2;
}

vec3 specularPBR(in vec2 coord, vec3 color, vec3 Normal, vec3 Tangent, vec3 View) {
    #ifdef ENABLE_NORMAL
        //R: Right (real normal component)
        //G: Down (real normal component)
        //B: Ambient Occlusion
        //A: Heightmap
        vec4 textureN = texture2D(normals, coord);
        //textureN.rg = textureN.rg * 2.0 - 1.0;

        //Recalculate the Z component of normal with XY component
        vec3 trueNormals = vec3(textureN.rg, sqrt(1.0 - dot(textureN.rg, textureN.rg)));
        //trueNormals = normalize(trueNormals);
        trueNormals = normalize(clamp(trueNormals * 2.0 - 1.0, -1.0, 1.0));

        vec3 T = normalize((gl_ModelViewMatrix * vec4(Tangent, 1.0)).xyz);
        vec3 N = Normal;
        vec3 B = normalize(cross(N, T));

        mat3 TBN = mat3(
            T.x, B.x, N.x,
            T.y, B.y, N.y,
            T.z, B.z, N.z
        );
        TBN = transpose(TBN);

        vec3 Nn = TBN * trueNormals;
    #else
        vec3 Nn = Normal;
    #endif

    //R: Smoothness
    //G: Reflectance (0 - 229), Metalness (230 - 255)
    //B: Dielectric: Porosity (0 - 64), Subsurface Scattering (65 - 255) / Metals: Reserved
    //A: Emissiveness (0 - 254)
    //Source: https://github.com/rre36/lab-pbr/wiki/Specular-Texture-Details
    vec4 textureS = texture2D(specular, coord);

    //Calculating specular component
    vec3 lightDir = normalize(shadowLightPosition);
    vec3 viewDir = normalize(-View);
    vec3 halfway = normalize(lightDir + viewDir);

    vec3 F0 = vec3(textureS.g);//textureS.g * 230.0 < 230.0 ? vec3(textureS.g) : vec3(1.0);
    if(textureS.b == 0.0)
    F0 = mix(F0, color.rgb, textureS.r);

    vec3 F = fresnelSchlick(max(dot(halfway, viewDir), 0.0), F0);

    float NDF = DistributionGGX(Nn, halfway, 1.0 - textureS.r);
    float G = GeometrySmith(Nn, viewDir, lightDir, 1.0 - textureS.r);

    vec3 numerator = NDF * G * F;
    float denominator = 2.0 * max(dot(Nn, viewDir), 0.0) * max(dot(Nn, lightDir), 0.0);

    vec3 PBR = numerator / max(denominator, 0.001);

    return clamp(color.rgb+PBR, 0.0, 1.0);
}