shader_type canvas_item;

void fragment() {
    // Get the current pixel color from the texture
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Set a threshold for "black" color
    float threshold = 0.1;

    // Check if the pixel is close to black
    if (tex_color.r < threshold && tex_color.g < threshold && tex_color.b < threshold) {
        // Make the pixel fully transparent if it is close to black
        tex_color.a = 0.0;
    }
    
    // Output the final color with potential transparency
    COLOR = tex_color;
}
