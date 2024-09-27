shader_type canvas_item;

uniform int transparent_rows = 0; // Number of rows from the bottom to make transparent

void fragment() {
	// Get the size of the sprite in pixels
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    float row_height = 1.0 / tex_size.y;

    float transparent_threshold = 1.0 - float(transparent_rows) * row_height;

    if (UV.y > transparent_threshold) {
        discard; // pixel transparent
    } else {
        COLOR = texture(TEXTURE, UV); // pixel visible
    }
}
