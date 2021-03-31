#define ENABLE_NORMAL //Enables or disables normal mapping

uniform sampler2D normals;
uniform vec3 sunPosition;

vec3 normalPBR(in vec2 coord, vec3 color, vec3 Normal, vec3 Tangent, vec3 View) {
    //R: Right (real normal component)
    //G: Down (real normal component)
    //B: Ambient Occlusion
    //A: Heightmap
    vec4 textureN = texture2D(normals, coord);

    //Recalculate the Z component of normal with XY component
	vec3 trueNormals = vec3(textureN.rg, sqrt(1.0 - dot(textureN.rg, textureN.rg)));
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

    vec3 norm = TBN * trueNormals;

    vec3 lightDir = normalize(sunPosition);
    vec3 viewDir = normalize(-View);
    vec3 halfway = normalize(lightDir + viewDir);

    float NdotH = pow(max(dot(norm, halfway), 0.0), 8.0);

    vec3 bump = vec3(NdotH);
    return clamp(color + (bump * 0.1), 0.0, 1.0);
}