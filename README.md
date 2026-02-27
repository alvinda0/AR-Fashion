# Fashion AR - Augmented Reality Fashion Try-On App

A Flutter-based AR application that allows users to visualize 3D fashion models in augmented reality.

## ✨ Features

- 📷 **AR Camera** - Real-time camera preview with AR capabilities
- 👗 **3D Fashion Models** - Interactive 3D models of fashion items
- 🔄 **Interactive Controls** - Drag to rotate, pinch to zoom
- 📱 **AR Mode** - View models in your real space (ARCore/ARKit)
- 🎨 **Multiple Items** - 8 different fashion items to try on

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode
- Blender (for FBX to GLB conversion)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd AR-Fashion
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Convert FBX models to GLB** ⚠️ REQUIRED
   
   The app uses GLB format for 3D models. You need to convert FBX files first:
   
   **Option A: Using Blender (Recommended)**
   - Install Blender from https://www.blender.org/download/
   - Run conversion script:
     - Windows: `convert_models.bat`
     - Mac/Linux: `./convert_models.sh`
   
   **Option B: Manual Conversion**
   - See detailed guide in `CONVERT_FBX_TO_GLB.md`
   
   **Option C: Online Converter**
   - Upload FBX files to https://products.aspose.app/3d/conversion/fbx-to-glb
   - Download GLB files and place in `assets/glb/`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
AR-Fashion/
├── lib/
│   ├── main.dart                    # App entry point
│   └── screens/
│       ├── ar_camera_screen.dart    # AR camera with 3D viewer
│       └── gallery_screen.dart      # Fashion items gallery
├── assets/
│   ├── fbx/                         # Original FBX models
│   ├── glb/                         # Converted GLB models (required)
│   └── images/                      # Fashion item thumbnails
├── android/                         # Android-specific code
├── ios/                             # iOS-specific code
└── docs/                            # Documentation files
```

## 📚 Documentation

- **[QUICK_START_3D.md](QUICK_START_3D.md)** - Quick start guide for 3D features
- **[CONVERT_FBX_TO_GLB.md](CONVERT_FBX_TO_GLB.md)** - Detailed FBX to GLB conversion guide
- **[3D_MODEL_USAGE.md](3D_MODEL_USAGE.md)** - Complete 3D model usage documentation
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Implementation details and summary

## 🎮 How to Use

1. Launch the app
2. Tap "AR Camera" or "Try On" button
3. Camera preview opens with fashion items at the bottom
4. **Tap any fashion item** to view its 3D model
5. Interact with the model:
   - **Drag** to rotate
   - **Pinch** to zoom in/out
   - **Tap X button** to close viewer
   - **Tap AR button** to view in AR mode (on supported devices)

## 🛠️ Technologies Used

- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **model_viewer_plus** - 3D model rendering
- **camera** - Camera access and preview
- **google_ml_kit** - ML Kit for pose detection
- **ARCore** (Android) / **ARKit** (iOS) - AR capabilities

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5+9
  permission_handler: ^11.3.1
  provider: ^6.1.2
  path_provider: ^2.1.3
  vector_math: ^2.1.4
  google_ml_kit: ^0.18.0
  model_viewer_plus: ^1.7.2
```

## 🎨 Fashion Items

The app includes 8 fashion items:

1. **Dayana** (Blue)
2. **Nayra** (Black)
3. **Sabrina** (Black & White variants)
4. **Valerya** (Pink)
5. **Xavia** (Black, Blue, Purple variants)

## 🔧 Configuration

### Android

Minimum SDK: 21 (Android 5.0)
Target SDK: 34 (Android 14)

Required permissions:
- Camera
- Internet
- Storage (Read/Write)

### iOS

Minimum iOS: 12.0

Required permissions:
- Camera
- Photo Library

## 🐛 Troubleshooting

### Models not showing
1. Ensure GLB files exist in `assets/glb/`
2. Check file names match exactly (case-sensitive)
3. Run `flutter clean && flutter pub get`
4. Check console for error messages

### Conversion errors
1. Ensure Blender is installed and in PATH
2. Try manual conversion one file at a time
3. Check FBX files are not corrupted

### Performance issues
1. Compress models using gltf-pipeline
2. Reduce polygon count in Blender
3. Resize textures to 1024x1024 or smaller

See detailed troubleshooting in documentation files.

## 📱 Supported Platforms

- ✅ Android (5.0+)
- ✅ iOS (12.0+)
- ⚠️ AR Mode requires:
  - Android: ARCore support
  - iOS: ARKit support

## 🚧 Known Issues

1. FBX files must be converted to GLB (not supported natively)
2. AR mode only works on physical devices (not emulators)
3. Large models may cause performance issues on low-end devices
4. Requires internet connection for model viewer library

## 🔮 Future Enhancements

- [ ] Loading indicators for model loading
- [ ] Error handling and user feedback
- [ ] Multiple camera angles (front/side/back)
- [ ] Animation support for models
- [ ] Screenshot and share functionality
- [ ] Favorites and saved items
- [ ] Size guide overlay
- [ ] Color variant switching
- [ ] Virtual try-on with pose detection

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contributors

- Your Name - Initial work

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- model_viewer_plus for 3D rendering capabilities
- Blender for 3D model conversion tools

## 📞 Support

For issues, questions, or contributions:
1. Check the documentation files
2. Review console error messages
3. Test models at https://gltf-viewer.donmccurdy.com/
4. Open an issue on GitHub

---

Made with ❤️ using Flutter
