#!/usr/bin/env python3
"""
Fashion AR - 3D Model Conversion Script
Converts FBX, OBJ, and other formats to GLB for Flutter app
"""

import os
import sys
import subprocess
import json
from pathlib import Path

class ModelConverter:
    def __init__(self):
        self.source_dir = Path("assets/models/source")
        self.output_dir = Path("assets/models/clothing")
        self.temp_dir = Path("assets/models/converted")
        
        # Create directories if they don't exist
        self.source_dir.mkdir(parents=True, exist_ok=True)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.temp_dir.mkdir(parents=True, exist_ok=True)
        
    def check_dependencies(self):
        """Check if required tools are installed"""
        tools = {
            'fbx2gltf': 'npm install -g fbx2gltf',
            'obj2gltf': 'npm install -g obj2gltf',
            'gltf-pipeline': 'npm install -g gltf-pipeline',
            'gltf_validator': 'npm install -g gltf-validator'
        }
        
        missing_tools = []
        for tool, install_cmd in tools.items():
            try:
                subprocess.run([tool, '--version'], 
                             capture_output=True, check=True)
                print(f"✅ {tool} is installed")
            except (subprocess.CalledProcessError, FileNotFoundError):
                print(f"❌ {tool} is not installed")
                print(f"   Install with: {install_cmd}")
                missing_tools.append(tool)
        
        if missing_tools:
            print(f"\n⚠️  Please install missing tools before continuing")
            return False
        return True
    
    def convert_fbx_to_glb(self, fbx_path, output_path):
        """Convert FBX file to GLB"""
        try:
            cmd = ['fbx2gltf', str(fbx_path), '-o', str(output_path)]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"✅ Converted {fbx_path.name} → {output_path.name}")
                return True
            else:
                print(f"❌ Failed to convert {fbx_path.name}")
                print(f"   Error: {result.stderr}")
                return False
        except Exception as e:
            print(f"❌ Error converting {fbx_path.name}: {e}")
            return False
    
    def convert_obj_to_glb(self, obj_path, output_path):
        """Convert OBJ file to GLB"""
        try:
            cmd = ['obj2gltf', '-i', str(obj_path), '-o', str(output_path)]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"✅ Converted {obj_path.name} → {output_path.name}")
                return True
            else:
                print(f"❌ Failed to convert {obj_path.name}")
                print(f"   Error: {result.stderr}")
                return False
        except Exception as e:
            print(f"❌ Error converting {obj_path.name}: {e}")
            return False
    
    def optimize_glb(self, input_path, output_path):
        """Optimize GLB file for mobile"""
        try:
            cmd = [
                'gltf-pipeline', 
                '-i', str(input_path), 
                '-o', str(output_path),
                '--draco.compressionLevel=7',
                '--draco.quantizePositionBits=11',
                '--draco.quantizeNormalBits=8',
                '--draco.quantizeTexcoordBits=10'
            ]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                # Get file sizes
                original_size = input_path.stat().st_size
                optimized_size = output_path.stat().st_size
                reduction = (1 - optimized_size/original_size) * 100
                
                print(f"✅ Optimized {input_path.name}")
                print(f"   Size: {original_size:,} → {optimized_size:,} bytes ({reduction:.1f}% reduction)")
                return True
            else:
                print(f"❌ Failed to optimize {input_path.name}")
                print(f"   Error: {result.stderr}")
                return False
        except Exception as e:
            print(f"❌ Error optimizing {input_path.name}: {e}")
            return False
    
    def validate_glb(self, glb_path):
        """Validate GLB file"""
        try:
            cmd = ['gltf_validator', str(glb_path)]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"✅ {glb_path.name} is valid")
                return True
            else:
                print(f"⚠️  {glb_path.name} has validation issues:")
                print(f"   {result.stdout}")
                return False
        except Exception as e:
            print(f"❌ Error validating {glb_path.name}: {e}")
            return False
    
    def get_category_from_filename(self, filename):
        """Determine category from filename"""
        filename_lower = filename.lower()
        
        if any(word in filename_lower for word in ['shirt', 'tshirt', 't-shirt', 'blouse']):
            return 'shirts'
        elif any(word in filename_lower for word in ['jacket', 'coat', 'blazer']):
            return 'jackets'
        elif any(word in filename_lower for word in ['dress', 'gown']):
            return 'dresses'
        elif any(word in filename_lower for word in ['pants', 'trousers', 'jeans']):
            return 'pants'
        elif any(word in filename_lower for word in ['hat', 'glasses', 'necklace', 'accessory']):
            return 'accessories'
        else:
            return 'misc'
    
    def convert_all_models(self):
        """Convert all models in source directory"""
        if not self.check_dependencies():
            return
        
        print("🔄 Starting model conversion process...\n")
        
        # Find all FBX files
        fbx_files = list(self.source_dir.rglob("*.fbx"))
        obj_files = list(self.source_dir.rglob("*.obj"))
        
        total_files = len(fbx_files) + len(obj_files)
        if total_files == 0:
            print("❌ No FBX or OBJ files found in source directory")
            print(f"   Place your files in: {self.source_dir}")
            return
        
        print(f"📁 Found {len(fbx_files)} FBX files and {len(obj_files)} OBJ files")
        print(f"📁 Output directory: {self.output_dir}\n")
        
        converted_count = 0
        
        # Convert FBX files
        for fbx_file in fbx_files:
            print(f"🔄 Processing {fbx_file.name}...")
            
            # Determine output category and filename
            category = self.get_category_from_filename(fbx_file.stem)
            output_dir = self.output_dir / category
            output_dir.mkdir(exist_ok=True)
            
            temp_glb = self.temp_dir / f"{fbx_file.stem}.glb"
            final_glb = output_dir / f"{fbx_file.stem}.glb"
            
            # Convert FBX to GLB
            if self.convert_fbx_to_glb(fbx_file, temp_glb):
                # Optimize GLB
                if self.optimize_glb(temp_glb, final_glb):
                    # Validate GLB
                    self.validate_glb(final_glb)
                    converted_count += 1
                    
                    # Clean up temp file
                    temp_glb.unlink(missing_ok=True)
            print()
        
        # Convert OBJ files
        for obj_file in obj_files:
            print(f"🔄 Processing {obj_file.name}...")
            
            # Determine output category and filename
            category = self.get_category_from_filename(obj_file.stem)
            output_dir = self.output_dir / category
            output_dir.mkdir(exist_ok=True)
            
            temp_glb = self.temp_dir / f"{obj_file.stem}.glb"
            final_glb = output_dir / f"{obj_file.stem}.glb"
            
            # Convert OBJ to GLB
            if self.convert_obj_to_glb(obj_file, temp_glb):
                # Optimize GLB
                if self.optimize_glb(temp_glb, final_glb):
                    # Validate GLB
                    self.validate_glb(final_glb)
                    converted_count += 1
                    
                    # Clean up temp file
                    temp_glb.unlink(missing_ok=True)
            print()
        
        print(f"✅ Conversion complete!")
        print(f"   Successfully converted: {converted_count}/{total_files} files")
        print(f"   Output location: {self.output_dir}")
        
        # Generate Flutter data service entries
        self.generate_flutter_entries()
    
    def generate_flutter_entries(self):
        """Generate Flutter FashionItem entries for converted models"""
        print("\n📝 Generating Flutter data entries...")
        
        entries = []
        for category_dir in self.output_dir.iterdir():
            if category_dir.is_dir():
                category = category_dir.name
                for glb_file in category_dir.glob("*.glb"):
                    entry = f'''FashionItem(
  id: '{glb_file.stem}',
  name: '{glb_file.stem.replace("_", " ").title()}',
  category: '{category}',
  modelPath: 'assets/models/clothing/{category}/{glb_file.name}',
  thumbnailPath: 'assets/images/{glb_file.stem}_thumb.jpg',
  description: 'Converted from source model',
  colors: ['Default'],
  sizes: ['S', 'M', 'L'],
  price: 100000,
),'''
                    entries.append(entry)
        
        if entries:
            output_file = Path("generated_fashion_items.dart")
            with open(output_file, 'w') as f:
                f.write("// Generated Fashion Items\n")
                f.write("// Add these to your fashion_data_service.dart\n\n")
                f.write("\n".join(entries))
            
            print(f"✅ Generated Flutter entries: {output_file}")
            print("   Copy the entries to lib/services/fashion_data_service.dart")

def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--check':
        converter = ModelConverter()
        converter.check_dependencies()
    else:
        converter = ModelConverter()
        converter.convert_all_models()

if __name__ == "__main__":
    main()