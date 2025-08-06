shader_type canvas_item;

uniform float time : hint_range(0, 1000);
uniform vec4 fog_color : source_color = vec4(0.2, 0.4, 0.6, 0.5);

void fragment() {
    vec2 uv = UV;

    // Fake water movement
    float wave = sin((uv.y + time * 0.2) * 10.0) * 0.01;
    uv.x += wave;

    COLOR = fog_color;
}
