shader_type canvas_item;

uniform int transparent_rows = 0; // Number of rows from the bottom to make transparent

void fragment() {
    // Get the size of the sprite in pixels
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    float row_height = 1.0 / tex_size.y;

    // Calculate the threshold where full transparency starts (everything below this is fully transparent)
    float transparent_threshold = 1.0 - float(transparent_rows) * row_height;

    // Calculate the threshold for the topmost transparent row
    float checkerboard_threshold = transparent_threshold + row_height;

    // If transparent_rows is 0, make the entire sprite visible
    if (transparent_rows == 0) {
        COLOR = texture(TEXTURE, UV); // Make the pixel fully visible
    } 
    // If the current pixel is in fully transparent rows
    else if (UV.y > transparent_threshold) {
        discard; // Make the pixel fully transparent
    } 
    // If the current pixel is in the topmost row (that gets the checkerboard effect)
    else if (UV.y > transparent_threshold - row_height) {
        // Calculate the exact pixel position in the texture space (for X-axis)
        int x = int(floor(UV.x * tex_size.x));

        // Checkerboard pattern: discard every second pixel
        if (x % 2 == 0) {
            discard; // Make every second pixel transparent
        } else {
            COLOR = texture(TEXTURE, UV); // Otherwise, make the pixel visible
        }
    } 
    // Otherwise, make the pixel fully visible (above the transparent area)
    else {
        COLOR = texture(TEXTURE, UV); // Make the pixel visible
    }
}
