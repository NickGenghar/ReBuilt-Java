#define ENABLE_NORMAL //Enables or disables normal mapping

uniform sampler2D normals;
uniform vec3 sunPosition;

vec3 normalPBR(in vec2 coord, vec3 color, vec3 ambient, mat3 TBN, vec3 Normal, vec3 View) {
    //R: Right (real normal component)
    //G: Down (real normal component)
    //B: Ambient Occlusion
    //A: Heightmap
    vec4 textureN = texture2D(normals, coord);

    //Recalculate the Z component of normal with XY component
	vec3 trueNormals = vec3(textureN.rg, sqrt(1.0 - dot(textureN.rg, textureN.rg)));
    trueNormals = normalize(clamp(trueNormals * 2.0 - 1.0, -1.0, 1.0));

    //TBN = transpose(TBN);

    vec3 norm = TBN * trueNormals;

    vec3 lightDir = normalize(sunPosition);
    vec3 viewDir = normalize(-View);
    vec3 halfway = normalize(lightDir + viewDir);

    float NdotH = pow(max(dot(norm, halfway), 0.0), 4.0);

    vec3 bump = vec3(NdotH);
    color += bump * 0.1 * ambient;
    color = clamp(color, 0.0, 1.0);

    return color;
}