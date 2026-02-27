#!/bin/bash
# Bash script to convert FBX to GLB using Blender
# Make sure Blender is installed and added to PATH

echo "========================================"
echo "FBX to GLB Converter"
echo "========================================"
echo ""

# Check if Blender is installed
if ! command -v blender &> /dev/null; then
    echo "ERROR: Blender not found in PATH"
    echo ""
    echo "Please install Blender from: https://www.blender.org/download/"
    echo "And add it to your system PATH"
    echo ""
    echo "Or run this script with full path to blender:"
    echo "/Applications/Blender.app/Contents/MacOS/Blender --background --python convert_fbx_to_glb.py"
    echo ""
    exit 1
fi

echo "Blender found! Starting conversion..."
echo ""

# Run Blender in background mode with Python script
blender --background --python convert_fbx_to_glb.py

echo ""
echo "========================================"
echo "Conversion complete!"
echo "Check assets/glb/ folder for output files"
echo "========================================"
echo ""
