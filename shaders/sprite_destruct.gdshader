shader_type spatial;

uniform sampler2D sprite_texture;
uniform float time;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898, 78.233))) * 43758.5453);
}

float simplexNoise(vec2 P)
{
    vec2 Pi = floor(P);
    vec2 Pf = P - Pi;

    vec4 Pxy = vec4(Pi.xy, Pi.xy + vec2(1.0));
    vec4 p = vec4(rand(Pxy.xy), rand(Pxy.zy), rand(Pxy.xw), rand(Pxy.zw));

    vec4 oxay = vec4(p.x, p.z, p.x, p.z);
    vec4 oxby = vec4(p.y, p.y, p.w, p.w);
    vec4 dx = Pf.xxxx - oxay;
    vec4 dy = Pf.yyyy - oxby;

    vec4 oooo = vec4(p.x, p.y, p.x, p.y);
    vec4 grad = vec4(dx.x, dx.z, dx.x, dx.z) * vec4(dy.y, dy.y, dy.w, dy.w);

    vec4 v = vec4(1.0) - abs(grad) * abs(grad);
    vec4 ograd = vec4(oooo.x, oooo.z, oooo.x, oooo.z) + grad * v;

    vec4 ogradx = vec4(ograd.x, ograd.z, ograd.x, ograd.z);
    vec4 ogrady = vec4(ograd.y, ograd.y, ograd.w, ograd.w);

    vec4 o = vec4(ogradx.x, ogrady.x, ogradx.y, ogrady.y);

    vec4 blend = vec4(Pf.x, Pf.y, 1.0 - Pf.x, 1.0 - Pf.y);
    vec4 n = blend.xxxx * o.xxxx + blend.yyyy * o.yyyy + blend.zzzz * o.zzzz + blend.wwww * o.wwww;

    return dot(vec4(41.0), n);
}

void vertex()
{
    // Calculate the displacement using Simplex noise
    float displacement = 0.1 * simplexNoise(UV + time);
    
    // Apply the displacement to the vertex position
    VERTEX += vec3(displacement, displacement, 0.0);
    
    // Transform the vertex position by the model, view, and projection matrices
    MAT4 model_matrix = mat4(UNITY_MATRIX_M);
    MAT4 view_matrix = mat4(UNITY_MATRIX_V);
    MAT4 projection_matrix = mat4(UNITY_MATRIX_P);
    VERTEX = projection_matrix * view_matrix * model_matrix * VERTEX;
    
    // Pass the UV coordinates to the fragment shader
    UV = VERTEX.xy;
}

void fragment()
{
    // Sample the sprite texture using the UV coordinates
    vec4 tex_color = texture(sprite_texture, UV);
    
    // Output the final color
    COLOR = tex_color;
}