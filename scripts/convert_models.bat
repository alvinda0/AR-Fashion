@echo off
REM Fashion AR - Model Conversion Script for Windows
REM Converts FBX and OBJ files to GLB format

echo ========================================
echo Fashion AR - 3D Model Converter
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python from https://python.org
    pause
    exit /b 1
)

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org
    pause
    exit /b 1
)

echo Checking dependencies...
echo.

REM Check if conversion tools are installed
fbx2gltf --version >nul 2>&1
if errorlevel 1 (
    echo Installing fbx2gltf...
    npm install -g fbx2gltf
)

obj2gltf --version >nul 2>&1
if errorlevel 1 (
    echo Installing obj2gltf...
    npm install -g obj2gltf
)

gltf-pipeline --version >nul 2>&1
if errorlevel 1 (
    echo Installing gltf-pipeline...
    npm install -g gltf-pipeline
)

gltf_validator --version >nul 2>&1
if errorlevel 1 (
    echo Installing gltf-validator...
    npm install -g gltf-validator
)

echo.
echo Dependencies check complete!
echo.

REM Create necessary directories
if not exist "assets\models\source" mkdir "assets\models\source"
if not exist "assets\models\source\fbx" mkdir "assets\models\source\fbx"
if not exist "assets\models\source\obj" mkdir "assets\models\source\obj"
if not exist "assets\models\converted" mkdir "assets\models\converted"
if not exist "assets\models\clothing" mkdir "assets\models\clothing"
if not exist "assets\models\clothing\shirts" mkdir "assets\models\clothing\shirts"
if not exist "assets\models\clothing\jackets" mkdir "assets\models\clothing\jackets"
if not exist "assets\models\clothing\dresses" mkdir "assets\models\clothing\dresses"

echo Directory structure created!
echo.

REM Run the Python conversion script
echo Starting conversion process...
python scripts\convert_models.py

echo.
echo ========================================
echo Conversion process completed!
echo ========================================
echo.
echo Next steps:
echo 1. Check the converted GLB files in assets\models\clothing\
echo 2. Add thumbnail images to assets\images\
echo 3. Update lib\services\fashion_data_service.dart with new items
echo 4. Run 'flutter pub get' and test the app
echo.
pause