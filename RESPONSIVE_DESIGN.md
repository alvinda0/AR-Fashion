# Fashion AR - Responsive Design Guide

## 📱 Responsive Design Implementation

Aplikasi Fashion AR telah dioptimalkan untuk berbagai ukuran layar dengan menggunakan responsive design patterns yang modern.

## 🎯 Breakpoints & Device Support

### Device Categories
- **Phone Portrait**: Width < 600px, Height > Width
- **Phone Landscape**: Width < 600px, Width > Height  
- **Tablet Portrait**: Width ≥ 600px, Height > Width
- **Tablet Landscape**: Width ≥ 600px, Width > Height

### Breakpoint Logic
```dart
final screenSize = MediaQuery.of(context).size;
final isTablet = screenSize.width > 600;
final isLandscape = screenSize.width > screenSize.height;
```

## 🏗️ Responsive Components

### 1. Home Screen (main.dart)

#### Portrait Layout
- **Phone**: Single column layout dengan padding 24px
- **Tablet**: Single column dengan padding 48px, ukuran elemen lebih besar

#### Landscape Layout (Phone)
- **Row Layout**: Logo & title di kiri, features & button di kanan
- **Compact Spacing**: Reduced vertical spacing untuk landscape
- **Optimized Sizes**: Smaller elements untuk landscape view

#### Responsive Elements
```dart
// Logo size
final logoSize = isTablet ? 150.0 : 120.0;

// Typography
final titleSize = isTablet ? 40.0 : 32.0;
final subtitleSize = isTablet ? 20.0 : 16.0;

// Padding
padding: EdgeInsets.symmetric(
  horizontal: isTablet ? 48 : 24,
  vertical: isLandscape ? 16 : 24,
),
```

### 2. AR Camera Screen

#### Responsive Overlays
- **3D Model Overlay**: Adaptive size berdasarkan screen constraints
- **Fashion Selector**: Height 300px (phone) / 400px (tablet)
- **Control Buttons**: Size 56px (phone) / 64px (tablet)

#### Layout Adaptations
```dart
// 3D Model sizing
final modelHeight = isLandscape 
    ? constraints.maxHeight * 0.6 
    : constraints.maxHeight * 0.5;
final modelWidth = isTablet ? 400.0 : constraints.maxWidth * 0.8;

// Button sizing
final buttonSize = isTablet ? 64.0 : 56.0;
```

### 3. Fashion Selector Widget

#### Grid Layout
- **Phone**: 2 columns grid
- **Tablet**: 3 columns grid
- **Adaptive Spacing**: 12px (phone) / 16px (tablet)

#### Card Design
```dart
final crossAxisCount = isTablet ? 3 : 2;
final childAspectRatio = isTablet ? 0.85 : 0.8;
final spacing = isTablet ? 16.0 : 12.0;
```

## 🎨 Typography Scale

### Responsive Font Sizes

#### Home Screen
```dart
// Title
Phone: 32px
Tablet: 40px

// Subtitle  
Phone: 16px
Tablet: 20px

// Feature Title
Phone: 16px
Tablet: 18px

// Feature Description
Phone: 12px
Tablet: 14px
```

#### AR Camera Screen
```dart
// App Bar Title
Phone: 18px
Tablet: 20px

// Instructions Title
Phone: 16px
Tablet: 18px

// Instructions Description
Phone: 12px
Tablet: 14px
```

#### Fashion Selector
```dart
// Header Title
Phone: 18px
Tablet: 22px

// Tab Labels
Phone: 14px
Tablet: 16px

// Item Name
Phone: 12px
Tablet: 14px

// Item Price
Phone: 11px
Tablet: 13px
```

## 📐 Spacing & Layout

### Responsive Spacing System
```dart
// Padding
Small: 8px / 12px (tablet)
Medium: 16px / 20px (tablet)  
Large: 24px / 32px (tablet)
XLarge: 32px / 48px (tablet)

// Margins
Small: 4px / 6px (tablet)
Medium: 8px / 12px (tablet)
Large: 16px / 24px (tablet)
```

### Container Sizing
```dart
// Icon containers
Phone: 48x48px
Tablet: 56x56px

// Button height
Phone: 56px
Tablet: 64px

// Card border radius
Phone: 12px
Tablet: 16px
```

## 🔧 Implementation Techniques

### 1. MediaQuery Usage
```dart
final screenSize = MediaQuery.of(context).size;
final isTablet = screenSize.width > 600;
```

### 2. LayoutBuilder for Constraints
```dart
LayoutBuilder(
  builder: (context, constraints) {
    return _buildResponsiveLayout(constraints);
  },
)
```

### 3. Conditional Layouts
```dart
isLandscape && !isTablet
    ? _buildLandscapeLayout(screenSize)
    : _buildPortraitLayout(screenSize, isTablet)
```

### 4. Responsive Widgets
```dart
Widget _buildResponsiveButton(bool isTablet) {
  return SizedBox(
    height: isTablet ? 64 : 56,
    child: ElevatedButton(
      // button content
    ),
  );
}
```

## 📱 Device Testing

### Recommended Test Devices

#### Phones
- **iPhone SE (375x667)**: Small phone portrait
- **iPhone 12 (390x844)**: Standard phone portrait  
- **Pixel 4 (411x869)**: Android phone portrait
- **Phone Landscape**: Any phone rotated

#### Tablets
- **iPad (768x1024)**: Standard tablet portrait
- **iPad Pro (834x1194)**: Large tablet portrait
- **Android Tablet (800x1280)**: Android tablet
- **Tablet Landscape**: Any tablet rotated

### Testing Checklist
- [ ] Text readability pada semua ukuran
- [ ] Button accessibility (min 44px touch target)
- [ ] Image scaling yang proper
- [ ] Layout tidak overflow
- [ ] Navigation yang konsisten
- [ ] Performance pada device rendah

## 🎯 Best Practices

### 1. **Mobile First Approach**
- Design untuk phone terlebih dahulu
- Progressive enhancement untuk tablet
- Graceful degradation untuk screen kecil

### 2. **Flexible Layouts**
- Gunakan Flex widgets (Column, Row)
- Avoid fixed dimensions
- Use constraints-based sizing

### 3. **Consistent Spacing**
- Define spacing constants
- Use consistent padding/margin ratios
- Scale spacing proportionally

### 4. **Typography Hierarchy**
- Maintain readable font sizes
- Scale typography proportionally
- Ensure sufficient contrast

### 5. **Touch Targets**
- Minimum 44px touch targets
- Adequate spacing between interactive elements
- Consider thumb reach zones

## 🔍 Debugging Responsive Issues

### Flutter Inspector
```dart
// Enable debug painting
import 'package:flutter/rendering.dart';
debugPaintSizeEnabled = true;
```

### Device Preview Plugin
```yaml
dev_dependencies:
  device_preview: ^1.1.0
```

### Custom Debug Info
```dart
Widget _buildDebugInfo() {
  return Positioned(
    top: 0,
    right: 0,
    child: Container(
      padding: EdgeInsets.all(8),
      color: Colors.black54,
      child: Text(
        'W: ${MediaQuery.of(context).size.width.toInt()}\n'
        'H: ${MediaQuery.of(context).size.height.toInt()}\n'
        'Tablet: ${MediaQuery.of(context).size.width > 600}',
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
    ),
  );
}
```

## 📊 Performance Considerations

### 1. **Efficient Rebuilds**
- Use const constructors where possible
- Minimize widget rebuilds
- Cache expensive calculations

### 2. **Image Optimization**
- Use appropriate image resolutions
- Implement lazy loading
- Consider device pixel ratio

### 3. **Memory Management**
- Dispose controllers properly
- Avoid memory leaks in responsive widgets
- Monitor memory usage on different devices

## 🚀 Future Enhancements

### 1. **Advanced Breakpoints**
- Support for foldable devices
- Desktop web support
- TV/large screen optimization

### 2. **Dynamic Typography**
- System font size respect
- Accessibility font scaling
- Custom typography themes

### 3. **Adaptive UI**
- Platform-specific designs
- Context-aware layouts
- User preference adaptation

---

**Responsive Design = Better User Experience! 📱✨**