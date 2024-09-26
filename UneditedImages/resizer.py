from PIL import Image
import os

def resize_image(image_path):
    try:
        with Image.open(image_path) as img:
            # Calculate the new dimensions
            new_width = img.width // 2
            new_height = img.height // 2

            # Resize the image
            resized_img = img.resize((new_width, new_height), Image.NEAREST)

            # Save the image with the same file path and format
            resized_img.save(image_path)
            print(f"Resized and saved: {image_path}")

    except Exception as e:
        print(f"Error processing {image_path}: {e}")

def resize_images_in_folder(folder_path):
    # Supported image formats
    supported_formats = (".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tiff", ".webp")

    # os.walk traverses the folder and all its subfolders
    for root, _, files in os.walk(folder_path):
        for file in files:
            # Check if the file is an image
            if file.lower().endswith(supported_formats):
                file_path = os.path.join(root, file)
                resize_image(file_path)

# Resize images in the current directory and all subdirectories
resize_images_in_folder(".")
