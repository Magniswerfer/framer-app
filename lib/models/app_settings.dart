// Removed unused import: import 'dart:convert';
import '../constants/app_constants.dart';

class AppSettings {
  // Slider configuration
  final int photoSizeSteps; // Number of steps (e.g., 10)
  final double minPhotoSizePercent; // Smallest size (e.g., 0.5 for 50%)
  final double maxPhotoSizePercent; // Largest size (e.g., 0.95 for 95%)

  // Defaults
  final int defaultPhotoSizeStep; // Default step for the slider (1-based)
  final String defaultAspectRatio; // Default frame aspect ratio

  AppSettings({
    this.photoSizeSteps = 10,
    this.minPhotoSizePercent = 0.5,
    this.maxPhotoSizePercent = 0.95,
    this.defaultPhotoSizeStep = 5, // Default to middle step
    this.defaultAspectRatio = AppConstants.defaultFrameOption, // Use constant
  });

  // Ensure default step is within valid range
  int get validDefaultPhotoSizeStep =>
      defaultPhotoSizeStep.clamp(1, photoSizeSteps);
  // Calculate step value for default
  double get defaultPhotoSizeValue => validDefaultPhotoSizeStep.toDouble();

  // Serialization
  Map<String, dynamic> toJson() => {
    'photoSizeSteps': photoSizeSteps,
    'minPhotoSizePercent': minPhotoSizePercent,
    'maxPhotoSizePercent': maxPhotoSizePercent,
    'defaultPhotoSizeStep': defaultPhotoSizeStep,
    'defaultAspectRatio': defaultAspectRatio,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      photoSizeSteps: json['photoSizeSteps'] ?? 10,
      minPhotoSizePercent: json['minPhotoSizePercent'] ?? 0.5,
      maxPhotoSizePercent: json['maxPhotoSizePercent'] ?? 0.95,
      defaultPhotoSizeStep: json['defaultPhotoSizeStep'] ?? 5,
      defaultAspectRatio:
          json['defaultAspectRatio'] ?? AppConstants.defaultFrameOption,
    );
  }

  // Helper to get the size ratio for a given step (1-based)
  double getRatioForStep(double step) {
    if (photoSizeSteps <= 1) {
      return minPhotoSizePercent; // Avoid division by zero
    }
    final double stepFraction = (step - 1) / (photoSizeSteps - 1);
    return minPhotoSizePercent +
        (maxPhotoSizePercent - minPhotoSizePercent) * stepFraction;
  }

  // Copy method for easy updates
  AppSettings copyWith({
    int? photoSizeSteps,
    double? minPhotoSizePercent,
    double? maxPhotoSizePercent,
    int? defaultPhotoSizeStep,
    String? defaultAspectRatio,
  }) {
    return AppSettings(
      photoSizeSteps: photoSizeSteps ?? this.photoSizeSteps,
      minPhotoSizePercent: minPhotoSizePercent ?? this.minPhotoSizePercent,
      maxPhotoSizePercent: maxPhotoSizePercent ?? this.maxPhotoSizePercent,
      defaultPhotoSizeStep: defaultPhotoSizeStep ?? this.defaultPhotoSizeStep,
      defaultAspectRatio: defaultAspectRatio ?? this.defaultAspectRatio,
    );
  }
}
