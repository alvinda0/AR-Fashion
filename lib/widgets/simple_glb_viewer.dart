import 'package:flutter/material.dart';
import '../models/fashion_item.dart';

class SimpleGLBViewer extends StatelessWidget {
  final FashionItem fashionItem;
  final bool isManualMode;
  final double animationValue;

  const SimpleGLBViewer({
    super.key,
    required this.fashionItem,
    required this.isManualMode,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            fashionItem.availableColors.first.withValues(alpha: 0.3),
            fashionItem.availableColors.first.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 3D-like representation - stable, no flickering
          Center(
            child: Transform.scale(
              scale: 1.0, // Keep stable scale
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3D cube icon with subtle rotation only in manual mode
                  Transform.rotate(
                    angle: isManualMode ? animationValue * 0.2 : 0,
                    child: Icon(
                      Icons.view_in_ar,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '3D Model Ready',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fashionItem.name,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Status indicator - stable
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'GLB Loaded',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // GLB indicator
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'GLB',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Status indicator
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
          // Interactive hint
          if (isManualMode)
            const Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                'Manual Mode Active',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}