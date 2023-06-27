import os
import sys
from pathlib import Path

def main():
    dir_in = sys.argv[1]
    dir_out = sys.argv[2]
    filter_ = sys.argv[3]

    # Create output directory if it doesn't exist
    Path(dir_out).mkdir(parents=True, exist_ok=True)

    # Get all files in input directory with filter in name
    files = [f for f in os.listdir(dir_in) if filter_ in f]

    # Move files to output directory
    for f in files:
        os.rename(os.path.join(dir_in, f), os.path.join(dir_out, f))

    # Print number of files moved
    print(f'{len(files)} files moved')

if __name__ == '__main__':
    main()