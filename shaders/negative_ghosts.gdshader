shader_type canvas_item;

uniform vec4 tint_color = vec4(0, 0.3, 1, 1); // Azul por defecto

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    color.rgb = mix(color.rgb, tint_color.rgb, 0.8); // Mezcla con azul
    COLOR = color;
}