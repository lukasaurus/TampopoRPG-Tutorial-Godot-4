from PIL import Image
import os

def split_image(image_path, rows, cols, output_folder):
    # Load the image
    img = Image.open(image_path)

    # Ensure the image is in RGBA mode (supports transparency)
    img = img.convert("RGBA")
    
    img_width, img_height = img.size

    # Calculate width and height of each tile
    tile_width = img_width // cols
    tile_height = img_height // rows

    # Create output folder for this specific image if it doesn't exist
    image_name = os.path.splitext(os.path.basename(image_path))[0]
    image_output_folder = os.path.join(output_folder, image_name)
    if not os.path.exists(image_output_folder):
        os.makedirs(image_output_folder)

    # Split image into tiles and save them
    tile_images = []
    tile_paths = []
    for row in range(rows):
        for col in range(cols):
            left = col * tile_width
            top = row * tile_height
            right = (col + 1) * tile_width
            bottom = (row + 1) * tile_height

            # Crop the image
            tile = img.crop((left, top, right, bottom))
            tile_images.append(tile)
            
            # Save the tile and store its path
            tile_path = os.path.join(image_output_folder, f"tile_r{row}_c{col}.png")
            tile.save(tile_path)
            tile_paths.append(tile_path)

    return tile_images, tile_paths


def remove_lines_and_save(tiles, tile_paths):
    for index, tile in enumerate(tiles):
        width, height = tile.size

        # Define which lines to remove (based on height / 4)
        lines_to_remove = [1, 22, 43, 64]  # These are sample values based on your request

        # Convert the image to a pixel array
        pixels = list(tile.getdata())
        pixels_per_row = width

        # Remove specific lines and the gap created
        new_pixels = []
        for row in range(height):
            if row not in lines_to_remove:
                new_pixels.extend(pixels[row * pixels_per_row:(row + 1) * pixels_per_row])

        # Create a new image with the updated pixel data
        new_height = height - len(lines_to_remove)
        new_image = Image.new("RGBA", (width, new_height))  # Ensure RGBA mode for transparency
        new_image.putdata(new_pixels)

        # Save the modified image, overwriting the original cut tile
        new_image.save(tile_paths[index])


def process_image(image_path, rows, cols, output_folder):
    # Split the image into tiles
    tiles, tile_paths = split_image(image_path, rows, cols, output_folder)

    # Process each tile (remove lines and gaps) and overwrite original cut files
    remove_lines_and_save(tiles, tile_paths)


def process_all_images_in_folder(rows, cols, output_folder, extensions=[".png", ".jpg", ".jpeg"]):
    current_folder = os.getcwd()  # Get the current working directory

    # Get a list of all image files in the current folder
    images = [f for f in os.listdir(current_folder) if os.path.isfile(f) and f.lower().endswith(tuple(extensions))]

    if not images:
        print("No images found in the current directory.")
        return

    # Process each image
    for image in images:
        print(f"Processing {image}...")
        image_path = os.path.join(current_folder, image)
        process_image(image_path, rows, cols, output_folder)


# Example usage
output_folder = "output_tiles"  # Folder where all output will be saved
rows = 2  # Specify number of rows
cols = 4  # Specify number of columns

# Process all images in the current folder
process_all_images_in_folder(rows, cols, output_folder)
