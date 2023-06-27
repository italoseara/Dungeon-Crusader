import os
import sys
from pathlib import Path
from PIL import Image
from pprint import pprint

STATES = ["idle", "walk", "run", "jump", "fall", "attack", "hit", "dead"]

def concat(images: list) -> Image:
    widths, heights = zip(*(i.size for i in images))

    total_width = sum(widths)
    max_height = max(heights)

    new_im = Image.new("RGBA", (total_width, max_height))

    x_offset = 0
    for im in images:
        new_im.paste(im, (x_offset, 0))
        x_offset += im.size[0]

    return new_im

def main() -> None:
    dir_in = Path(sys.argv[1])
    dir_out = Path(sys.argv[2])
    dir_out.mkdir(parents=True, exist_ok=True)

    files = os.listdir(dir_in)
    dict_anim = {}

    for file in files:
        # Check if it has a state in its name
        if file.split("_")[-3] not in STATES:
            name = "_".join(file.split("_")[:-2])
        
            if name not in dict_anim:
                dict_anim[name] = []
            dict_anim[name].append(file)
        else:
            state = file.split("_")[-3]
            name = "_".join(file.split("_")[:-3])
        
            if name not in dict_anim:
                dict_anim[name] = {}
            if state not in dict_anim[name]:
                dict_anim[name][state] = []
            
            dict_anim[name][state].append(file)

    for key, value in dict_anim.items():
        Path(dir_out, key).mkdir(parents=True, exist_ok=True)

        if type(value) is list:
            # Concatenate the images
            images = [Image.open(Path(dir_in, file)) for file in value]
            concat(images).save(Path(dir_out, key, key + ".png"))
        else:
            for state, files in value.items():
                # Concatenate the images
                images = [Image.open(Path(dir_in, file)) for file in files]
                concat(images).save(Path(dir_out, key, key + "_" + state + ".png"))

    pprint(dict_anim)

if __name__ == "__main__":
    main()