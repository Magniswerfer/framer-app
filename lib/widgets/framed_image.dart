import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FramedImage extends StatelessWidget {
  final dynamic image; // Can be File or XFile (web)
  final String? imageUrl; // For web
  final Color frameColor;
  final double photoSizeRatio; // Value from 0.5 to 0.95 based on slider
  final double aspectRatio;

  const FramedImage({
    required this.image,
    this.imageUrl,
    required this.frameColor,
    required this.photoSizeRatio,
    required this.aspectRatio,
    super.key,
  });

  Widget _buildImagePreview() {
    if (image == null) return const SizedBox.shrink();

    if (kIsWeb && imageUrl != null) {
      return Image.network(imageUrl!, fit: BoxFit.contain);
    } else if (!kIsWeb && image is File) {
      return Image.file(image, fit: BoxFit.contain);
    }
    // Handle XFile on web if needed, though imageUrl is likely preferred
    // else if (kIsWeb && image is XFile) {
    //   return Image.network(imageUrl!, fit: BoxFit.contain);
    // }
    return const SizedBox.shrink(); // Fallback
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameWidth = constraints.maxWidth;
        final frameHeight = frameWidth / aspectRatio;
        final baseSize = math.min(frameWidth, frameHeight);
        final calculatedPhotoSize = baseSize * photoSizeRatio;

        return AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            decoration: BoxDecoration(color: frameColor),
            child: Center(
              child: SizedBox(
                width: calculatedPhotoSize,
                height: calculatedPhotoSize,
                child: _buildImagePreview(),
              ),
            ),
          ),
        );
      },
    );
  }
}
