from PIL import Image, ImageDraw, ImageFont

# Create a new 256x256 image with a transparent background
img = Image.new('RGBA', (128, 128), color=(0, 0, 0, 0))
draw = ImageDraw.Draw(img)

tile_size = 16
num_tiles = 8
number = 1

# List of bright colors for outlines
bright_colours = [
    'red', 'green', 'blue', 'magenta', 'cyan', 'yellow',
    'orange', 'pink', 'purple', 'lime', 'gold', 'turquoise',
    'violet', 'indigo', 'crimson', 'teal'
]

# Load a bold TrueType font
# You may need to adjust the font path and size based on your system
font_size = 12  # Adjust font size to fit within the tiles
try:
    # Common font paths
    font = ImageFont.truetype('arialbd.ttf', font_size)  # For Windows
except IOError:
    try:
        font = ImageFont.truetype('Arial Bold.ttf', font_size)  # Alternative name
    except IOError:
        try:
            font = ImageFont.truetype('/Library/Fonts/Arial Bold.ttf', font_size)  # macOS
        except IOError:
            try:
                font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', font_size)  # Linux
            except IOError:
                # Fallback to default font if bold font not found
                font = ImageFont.load_default()
                print("Bold font not found. Using default font.")

for row in range(num_tiles):
    for col in range(num_tiles):
        left = col * tile_size
        top = row * tile_size
        right = left + tile_size
        bottom = top + tile_size

        # Choose a bright color for the outline
        colour = bright_colours[(number - 1) % len(bright_colours)]

        # Draw the rectangle outline
        draw.rectangle([left, top, right, bottom], outline=colour)

        # Prepare the number text
        number_str = str(number-1)

        # Calculate text bounding box
        bbox = font.getbbox(number_str)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]

        # Calculate text position to center it within the tile
        text_x = left + (tile_size - text_width) / 2 - bbox[0]
        text_y = top + (tile_size - text_height) / 2 - bbox[1]

        # Draw the number in the tile with white, bold font
        draw.text((text_x, text_y), number_str, fill='white', font=font)

        number += 1

# Save the image as a PNG file with transparency
img.save('tiles.png')
