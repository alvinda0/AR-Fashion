#!/usr/bin/env python3
"""
Batch convert FBX files to GLB format using Blender
Usage: blender --background --python convert_fbx_to_glb.py
"""

import bpy
import os
import sys

# Configuration
FBX_DIR = "assets/fbx"
GLB_DIR = "assets/glb"

# File mapping (FBX filename -> GLB filename)
FILE_MAPPING = {
    "dayana blue fbx.fbx": "dayana_blue.glb",
    "nayra black fbx.fbx": "nayra_black.glb",
    "sabrina black fbx.fbx": "sabrina_black.glb",
    "sabrina white fbx.fbx": "sabrina_white.glb",
    "valerya pink fbx.fbx": "valerya_pink.glb",
    "xavia black fbx.fbx": "xavia_black.glb",
    "xavia blue fbx.fbx": "xavia_blue.glb",
    "xavia blue old fbx.fbx": "xavia_blue_old.glb",
    "xavia purple fbx.fbx": "xavia_purple.glb",
}

def clear_scene():
    """Clear all objects from the scene"""
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)

def convert_fbx_to_glb(fbx_path, glb_path):
    """Convert a single FBX file to GLB"""
    try:
        print(f"Converting: {fbx_path} -> {glb_path}")
        
        # Clear scene
        clear_scene()
        
        # Import FBX
        bpy.ops.import_scene.fbx(filepath=fbx_path)
        
        # Export to GLB
        bpy.ops.export_scene.gltf(
            filepath=glb_path,
            export_format='GLB',
            export_apply=True,
            export_texcoords=True,
            export_normals=True,
            export_materials='EXPORT',
            export_colors=True,
            export_cameras=False,
            export_lights=False,
            export_yup=True,
        )
        
        print(f"✓ Successfully converted: {os.path.basename(glb_path)}")
        return True
        
    except Exception as e:
        print(f"✗ Error converting {fbx_path}: {str(e)}")
        return False

def main():
    """Main conversion function"""
    print("=" * 60)
    print("FBX to GLB Batch Converter")
    print("=" * 60)
    
    # Create output directory if it doesn't exist
    os.makedirs(GLB_DIR, exist_ok=True)
    
    # Convert each file
    success_count = 0
    fail_count = 0
    
    for fbx_filename, glb_filename in FILE_MAPPING.items():
        fbx_path = os.path.join(FBX_DIR, fbx_filename)
        glb_path = os.path.join(GLB_DIR, glb_filename)
        
        if not os.path.exists(fbx_path):
            print(f"⚠ Warning: FBX file not found: {fbx_path}")
            fail_count += 1
            continue
        
        if convert_fbx_to_glb(fbx_path, glb_path):
            success_count += 1
        else:
            fail_count += 1
    
    # Summary
    print("\n" + "=" * 60)
    print("Conversion Summary")
    print("=" * 60)
    print(f"✓ Successful: {success_count}")
    print(f"✗ Failed: {fail_count}")
    print(f"Total: {success_count + fail_count}")
    print("=" * 60)

if __name__ == "__main__":
    main()
