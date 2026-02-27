@echo off
REM Batch script to convert FBX to GLB using Blender
REM Make sure Blender is installed and added to PATH

echo ========================================
echo FBX to GLB Converter
echo ========================================
echo.

REM Check if Blender is installed
where blender >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Blender not found in PATH
    echo.
    echo Please install Blender from: https://www.blender.org/download/
    echo And add it to your system PATH
    echo.
    echo Or run this script with full path to blender.exe:
    echo "C:\Program Files\Blender Foundation\Blender 4.0\blender.exe" --background --python convert_fbx_to_glb.py
    echo.
    pause
    exit /b 1
)

echo Blender found! Starting conversion...
echo.

REM Run Blender in background mode with Python script
blender --background --python convert_fbx_to_glb.py

echo.
echo ========================================
echo Conversion complete!
echo Check assets/glb/ folder for output files
echo ========================================
echo.
pause
