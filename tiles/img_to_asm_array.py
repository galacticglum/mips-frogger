"""A command-line utility that generates the pixel data array for the given image."""
import math
import argparse
from pathlib import Path

from PIL import Image


def rgb_to_hex(r: int, g: int, b: int) -> str:
    """Converts RGB color to hexadecimal."""
    return f"{r:02x}{g:02x}{b:02x}"


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate MIPS assembly code for drawing an image.')
    parser.add_argument('image_filepath', type=Path, help='The path to the image file.')
    args = parser.parse_args()

    # load image and process it
    image = Image.open(args.image_filepath)
    image_width, image_height = image.size

    with open(args.image_filepath.with_suffix('.array.asm'), 'w+', encoding='utf-8') as fp:
        image_name = args.image_filepath.stem
        code = f'{image_name}: .word '
        colours = ['0x' + rgb_to_hex(*image.getpixel((x, y)))
                   for x in range(image_width)
                   for y in range(image_height)]
        code += ', '.join(colours) + '\n'
        code += f'{image_name}_width: .word {image_width}\n'
        code += f'{image_name}_size: .word {image_width * image_height}\n'
        fp.write(code)