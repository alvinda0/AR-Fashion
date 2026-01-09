#!/bin/bash
# Fashion AR - Model Conversion Script for Linux/macOS
# Converts FBX and OBJ files to GLB format

echo "========================================"
echo "Fashion AR - 3D Model Converter"
echo "========================================"
echo

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    echo "Please install Python 3 from https://python.org"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "ERROR: Node.js is not installed"
    echo "Please install Node.js from https://nodejs.org"
    exit 1
fi

echo "Checking dependencies..."
echo

# Check and install conversion tools
if ! command -v fbx2gltf &> /dev/null; then
    echo "Installing fbx2gltf..."
    npm install -g fbx2gltf
fi

if ! command -v obj2gltf &> /dev/null; then
    echo "Installing obj2gltf..."
    npm install -g obj2gltf
fi

if ! command -v gltf-pipeline &> /dev/null; then
    echo "Installing gltf-pipeline..."
    npm install -g gltf-pipeline
fi

if ! command -v gltf_validator &> /dev/null; then
    echo "Installing gltf-validator..."
    npm install -g gltf-validator
fi

echo
echo "Dependencies check complete!"
echo

# Create necessary directories
mkdir -p assets/models/source/{fbx,obj}
mkdir -p assets/models/converted
mkdir -p assets/models/clothing/{shirts,jackets,dresses,pants,accessories}

echo "Directory structure created!"
echo

# Make Python script executable
chmod +x scripts/convert_models.py

# Run the Python conversion script
echo "Starting conversion process..."
python3 scripts/convert_models.py

echo
echo "========================================"
echo "Conversion process completed!"
echo "========================================"
echo
echo "Next steps:"
echo "1. Check the converted GLB files in assets/models/clothing/"
echo "2. Add thumbnail images to assets/images/"
echo "3. Update lib/services/fashion_data_service.dart with new items"
echo "4. Run 'flutter pub get' and test the app"
echo