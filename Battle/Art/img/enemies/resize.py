from PIL import Image
import os

# Get the current directory
current_dir = os.getcwd()

# Loop through all files in the directory
for filename in os.listdir(current_dir):
    # Check if the file is an image (you can add more extensions if needed)
    if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.gif')):
        # Open the image
        img_path = os.path.join(current_dir, filename)
        img = Image.open(img_path)
        
        # Get the current size and scale it down by 3
        new_size = (img.width // 3, img.height // 3)
        
        # Resize the image using nearest neighbor algorithm
        img_resized = img.resize(new_size, Image.NEAREST)
        
        # Save the image (overwriting the old one)
        img_resized.save(img_path)

print("All images have been scaled down and overwritten.")