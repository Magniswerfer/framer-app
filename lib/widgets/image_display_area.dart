import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'framed_image.dart'; // Import FramedImage

class ImageDisplayArea extends StatelessWidget {
  final dynamic image;
  final String? imageUrl;
  final VoidCallback onPickImage;
  final GlobalKey repaintBoundaryKey;
  final Color frameColor;
  final double photoSizeRatio;
  final double aspectRatio;

  const ImageDisplayArea({
    required this.image,
    this.imageUrl,
    required this.onPickImage,
    required this.repaintBoundaryKey,
    required this.frameColor,
    required this.photoSizeRatio,
    required this.aspectRatio,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return image == null
        ? Container(
          height: 300,
          decoration: BoxDecoration(
            color: AppColors.textLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: Center(
            child: ElevatedButton.icon(
              onPressed: onPickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Upload Photo'),
            ),
          ),
        )
        : Container(
          decoration: BoxDecoration(
            color: AppColors.textLight, // Background for the shadow
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDark.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: RepaintBoundary(
            key: repaintBoundaryKey,
            child: FramedImage(
              image: image,
              imageUrl: imageUrl,
              frameColor: frameColor,
              photoSizeRatio: photoSizeRatio,
              aspectRatio: aspectRatio,
            ),
          ),
        );
  }
}
