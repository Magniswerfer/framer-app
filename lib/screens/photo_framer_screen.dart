import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:ui' as ui;

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../widgets/app_header.dart';
import '../widgets/image_display_area.dart';
import '../widgets/settings_panel.dart';
import '../models/app_settings.dart'; // Import settings model
import '../services/settings_service.dart'; // Import settings service
import 'settings_screen.dart'; // Re-add direct import if needed for navigation
import 'about_screen.dart'; // Import about screen for navigation

class PhotoFramerScreen extends StatefulWidget {
  const PhotoFramerScreen({super.key});

  @override
  State<PhotoFramerScreen> createState() => _PhotoFramerScreenState();
}

class _PhotoFramerScreenState extends State<PhotoFramerScreen> {
  // Settings
  final SettingsService _settingsService = SettingsService();
  AppSettings _appSettings = AppSettings(); // Start with default settings
  bool _settingsLoaded = false;

  // Image state
  dynamic _image;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _imageKey = GlobalKey();

  // Frame state (initialized after settings load)
  late String _selectedFrame;
  Color _frameColor = AppColors.textLight;
  late double _photoSizeStep; // Use step value (1 to steps)
  late String _selectedQuality;

  // Options (can still be hardcoded or fetched if needed)
  final List<String> _frameOptions = AppConstants.frameOptions;
  final List<String> _qualityOptions = AppConstants.qualityOptions;

  @override
  void initState() {
    super.initState();
    _loadAppSettings();
  }

  Future<void> _loadAppSettings() async {
    final loadedSettings = await _settingsService.loadSettings();
    setState(() {
      _appSettings = loadedSettings;
      // Initialize state based on loaded settings
      _selectedFrame = _appSettings.defaultAspectRatio;
      _photoSizeStep = _appSettings.defaultPhotoSizeValue;
      _selectedQuality =
          AppConstants.defaultQualityOption; // Keep default for now
      _settingsLoaded = true;
    });
  }

  // --- Utility Functions ---
  double _getPixelRatio() {
    switch (_selectedQuality) {
      case 'Original':
        return 1.0;
      case 'Good (0.75x)':
        return 0.75;
      case 'Medium (0.5x)':
        return 0.5;
      case 'Low (0.25x)':
        return 0.25;
      default:
        return 1.0;
    }
  }

  double _getAspectRatio() {
    switch (_selectedFrame) {
      case '1:1':
        return 1.0;
      case '5:4':
        return 5 / 4;
      case '4:5':
        return 4 / 5;
      case '2:3':
        return 2 / 3;
      case '3:2':
        return 3 / 2;
      default:
        return 1.0;
    }
  }

  // Calculate the ratio needed for FramedImage based on the current step and settings
  double _getPhotoSizeRatio() {
    return _appSettings.getRatioForStep(_photoSizeStep);
  }

  // --- Event Handlers ---
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      // Reset defaults when new image is picked
      final newFrame = _appSettings.defaultAspectRatio;
      final newSizeStep = _appSettings.defaultPhotoSizeValue;

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        final blob = web.Blob([bytes.buffer.toJS].toJS);
        if (_imageUrl != null) {
          web.URL.revokeObjectURL(_imageUrl!);
        }
        _imageUrl = web.URL.createObjectURL(blob);
        setState(() {
          _image = pickedFile;
          _selectedFrame = newFrame;
          _photoSizeStep = newSizeStep;
        });
      } else {
        setState(() {
          _image = File(pickedFile.path);
          _selectedFrame = newFrame;
          _photoSizeStep = newSizeStep;
        });
      }
    }
  }

  Future<void> _downloadImage() async {
    // 1. Check if image exists
    if (_image == null) return;

    try {
      // 2. Get original image bytes
      final bytes = await _image.readAsBytes();

      // 3. Decode image to get original dimensions
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final originalUiImage = frame.image;
      final originalWidth = originalUiImage.width.toDouble();
      final originalHeight = originalUiImage.height.toDouble();

      // 4. Calculate target photo dimensions based on quality
      final qualityFactor = _getPixelRatio();
      final targetPhotoWidth = originalWidth * qualityFactor;
      final targetPhotoHeight = originalHeight * qualityFactor;

      // 5. Calculate final output dimensions based on frame aspect ratio and photo size ratio
      final frameAspectRatio = _getAspectRatio();
      final photoSizeRatio =
          _getPhotoSizeRatio(); // How much of frame inner dimension photo takes

      // Determine the size of the frame's inner dimension needed to contain the photo
      // based on the photo taking up 'photoSizeRatio' of that dimension.
      final double innerDimension;
      if (targetPhotoWidth / targetPhotoHeight >= 1) {
        // Photo is landscape or square
        innerDimension = targetPhotoWidth / photoSizeRatio;
      } else {
        // Photo is portrait
        innerDimension = targetPhotoHeight / photoSizeRatio;
      }

      // Calculate the final output width/height based on the frame aspect ratio
      final double outputWidth;
      final double outputHeight;
      if (frameAspectRatio >= 1) {
        // Frame is landscape or square
        outputHeight = innerDimension;
        outputWidth = innerDimension * frameAspectRatio;
      } else {
        // Frame is portrait
        outputWidth = innerDimension;
        outputHeight = innerDimension / frameAspectRatio;
      }

      // 6. Draw Off-screen using PictureRecorder and Canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint();
      final outputRect = Rect.fromLTWH(0, 0, outputWidth, outputHeight);

      // Draw the frame background
      paint.color = _frameColor;
      canvas.drawRect(outputRect, paint);

      // Calculate the position to draw the photo (centered)
      final drawX = (outputWidth - targetPhotoWidth) / 2;
      final drawY = (outputHeight - targetPhotoHeight) / 2;
      final srcRect = Rect.fromLTWH(0, 0, originalWidth, originalHeight);
      final dstRect = Rect.fromLTWH(
        drawX,
        drawY,
        targetPhotoWidth,
        targetPhotoHeight,
      );

      // Draw the (potentially scaled) original image onto the canvas
      canvas.drawImageRect(originalUiImage, srcRect, dstRect, paint);

      // 7. Encode the picture to PNG bytes
      final picture = recorder.endRecording();
      // Use floor() to avoid potential issues with non-integer dimensions during encoding
      final finalUiImage = await picture.toImage(
        outputWidth.floor(),
        outputHeight.floor(),
      );
      final byteData = await finalUiImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      // 8. Download the generated bytes
      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        final String timestamp =
            DateTime.now().millisecondsSinceEpoch.toString();
        final String fileName = 'framed_photo_$timestamp.png';

        if (kIsWeb) {
          final blob = web.Blob(
            [pngBytes.buffer.toJS].toJS,
            web.BlobPropertyBag(type: 'image/png'),
          );
          final url = web.URL.createObjectURL(blob);
          final anchor = web.HTMLAnchorElement()..href = url;
          anchor.setAttribute('download', fileName);
          anchor.click();
          web.URL.revokeObjectURL(url);
        } else {
          final directory = await getTemporaryDirectory();
          final String filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(pngBytes);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image saved to: $filePath')),
            );
          }
        }
      }
    } catch (e) {
      // Add more specific error reporting if possible
      print('Error downloading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
      }
    }
  }

  // --- Add navigation handlers ---
  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    ).then((_) => _loadAppSettings()); // Reload settings when returning
  }

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    if (!_settingsLoaded) {
      // Show loading indicator while settings are loading
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('framer'),
        ), // Simple header while loading
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // --- Add Logging ---
    final currentRatio = _getPhotoSizeRatio();
    print('--- Build --- ');
    print('Settings Steps: ${_appSettings.photoSizeSteps}');
    print('Settings Min %: ${_appSettings.minPhotoSizePercent}');
    print('Settings Max %: ${_appSettings.maxPhotoSizePercent}');
    print('Current Step Value: $_photoSizeStep');
    print('Calculated Ratio: $currentRatio');
    print('-------------');
    // --- End Logging ---

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        // Pass navigation callbacks to AppHeader
        onSettingsPressed: _navigateToSettings,
        onAboutPressed: _navigateToAbout,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ImageDisplayArea(
                image: _image,
                imageUrl: _imageUrl,
                onPickImage: _pickImage,
                repaintBoundaryKey: _imageKey,
                frameColor: _frameColor,
                photoSizeRatio: currentRatio,
                aspectRatio: _getAspectRatio(),
              ),
              const SizedBox(height: 24),
              if (_image != null)
                SettingsPanel(
                  selectedFrame: _selectedFrame,
                  frameOptions: _frameOptions,
                  onFrameChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedFrame = newValue;
                      });
                    }
                  },
                  frameColor: _frameColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      _frameColor = color;
                    });
                  },
                  photoSize: _photoSizeStep,
                  photoSizeSteps: _appSettings.photoSizeSteps,
                  onPhotoSizeChanged: (double value) {
                    setState(() {
                      _photoSizeStep = value;
                    });
                  },
                  selectedQuality: _selectedQuality,
                  qualityOptions: _qualityOptions,
                  onQualityChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedQuality = newValue;
                      });
                    }
                  },
                  onDownload: _downloadImage,
                  onReUpload: _pickImage,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Clean up blob URL when the widget is disposed (for web)
  @override
  void dispose() {
    if (kIsWeb && _imageUrl != null) {
      web.URL.revokeObjectURL(_imageUrl!);
    }
    super.dispose();
  }
}
