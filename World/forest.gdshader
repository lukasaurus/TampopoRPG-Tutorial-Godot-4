shader_type canvas_item;

uniform int transparent_rows = 2; // Number of rows from the bottom to make transparent

void fragment() {
    vec2 tex_size = vec2(textureSize(TEXTURE, 0)); // Get the size of the sprite in pixels
    float row_height = 1.0 / tex_size.y; // Height of a single row in UV space

    // Calculate the UV.y threshold for transparency from the bottom
    float transparent_threshold = 1.0 - float(transparent_rows) * row_height;

    // If the current UV.y is within the bottom transparent rows
    if (UV.y > transparent_threshold) {
        discard; // Make the pixel transparent
    } else {
        COLOR = texture(TEXTURE, UV); // Keep the pixel visible
    }
}
