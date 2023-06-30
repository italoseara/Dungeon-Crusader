import os
import sys
from pathlib import Path

def main():
    dir_in = sys.argv[1]

    for root, dirs, files in os.walk(dir_in):
        for dir in dirs:
            dir_path = os.path.join(root, dir)
            dir_files = os.listdir(dir_path)
            if len(dir_files) == 1:
                file_path = os.path.join(dir_path, dir_files[0])
                os.rename(file_path, os.path.join(root, dir_files[0]))
                os.rmdir(dir_path)
    
if __name__ == '__main__':
    main()