#!/bin/bash
# Path to the file containing directories
DIR_FILE="directories.txt"
# Read each line (directory path) from the file
while IFS= read -r dir
do
# Check if the directory exists
if [ -d "$dir" ]; then
# Use find to touch all files in the directory and its subdirectories
find "$dir" -type f -exec touch {} +
else
echo "Directory does not exist: $dir"
fi
done < "$DIR_FILE"
