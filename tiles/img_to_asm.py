"""A command-line utility that generates the MIPS assembly code that draws the given image."""
import math
import argparse
from pathlib import Path

from PIL import Image
from webcolors import rgb_to_name


def rgb_to_hex(r: int, g: int, b: int) -> str:
    """Converts RGB color to hexadecimal."""
    return f"{r:02x}{g:02x}{b:02x}"


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate MIPS assembly code for drawing an image.')
    parser.add_argument('image_filepath', type=Path, help='The path to the image file.')
    parser.add_argument('--base_display_addr', type=int, default=0x10008000, help='The base address of the display.')
    parser.add_argument('--screen-width', type=int, default=256, help='The width of the screen.')
    parser.add_argument('--unit-width', type=int, default=1, help='The width of a single unit.')
    args = parser.parse_args()

    screen_width_log2 = math.log2(args.screen_width)
    unit_width_log2 = math.log2(args.unit_width)

    # make sure screen_width_log2 and unit_width_log2 are both integers
    assert screen_width_log2 == int(screen_width_log2) and unit_width_log2 == int(unit_width_log2)

    # load image and process it
    image = Image.open(args.image_filepath)
    image_width, image_height = image.size

    with open(args.image_filepath.with_suffix('.asm'), 'w+', encoding='utf-8') as fp:
        image_name = args.image_filepath.stem
        code = f'draw_sprite_{image_name}:\n'

        # offset = $a0 * (width / unit_width) + $a1
        k = int(math.log2(args.screen_width / args.unit_width))
        code += f'\tsll $a0, $a0, 2  # multiply $a0 by 4\n'
        code += f'\tsll $a1, $a1, {k + 2} # multiply $a1 by 4 * {int(math.pow(2, k))}\n'
        code += f'\tadd $t0, $a0, $a1\n'

        # map pixel colours to positions in the display
        pixels_by_colour = {}
        for x in range(image_width):
            for y in range(image_height):
                pixel = image.getpixel((x, y))
                if len(pixel) == 4 and pixel[3] == 0:
                    # ignore transparent pixels
                    continue

                i = y * args.screen_width // args.unit_width + x
                addr = hex(args.base_display_addr + i * 4)

                colour = '0x' + rgb_to_hex(*pixel[:3])
                if colour not in pixels_by_colour:
                    pixels_by_colour[colour] = set()
                pixels_by_colour[colour].add(addr)

        for colour, addresses in pixels_by_colour.items():
            code += f'\tli $t1, {colour} # store colour code for {colour}\n'
            for addr in addresses:
                code += f'\tsw $t1, {addr}($t0) # draw pixel\n'
        # return 
        code += '\tjr $ra'


        fp.write(code)