#!/bin/bash
# cleanup.sh - Remove unwanted .jpg files from the repo before deploy

echo "Cleaning up .jpg files..."

# Remove all .jpg files recursively
find . -type f -name "*.jpg" -exec rm -v {} \;

echo "Cleanup complete."
