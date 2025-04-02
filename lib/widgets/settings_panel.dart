import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../constants/app_colors.dart';
import 'custom_dropdown.dart';
import 'section_title.dart';

class SettingsPanel extends StatelessWidget {
  final String selectedFrame;
  final List<String> frameOptions;
  final void Function(String?) onFrameChanged;

  final Color frameColor;
  final void Function(Color) onColorChanged;

  final double photoSize;
  final int photoSizeSteps;
  final void Function(double) onPhotoSizeChanged;

  final String selectedQuality;
  final List<String> qualityOptions;
  final void Function(String?) onQualityChanged;

  final VoidCallback onDownload;
  final VoidCallback onReUpload;

  const SettingsPanel({
    required this.selectedFrame,
    required this.frameOptions,
    required this.onFrameChanged,
    required this.frameColor,
    required this.onColorChanged,
    required this.photoSize,
    required this.photoSizeSteps,
    required this.onPhotoSizeChanged,
    required this.selectedQuality,
    required this.qualityOptions,
    required this.onQualityChanged,
    required this.onDownload,
    required this.onReUpload,
    super.key,
  });

  void _showColorPickerDialog(BuildContext context, Color currentColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color selectedColor = currentColor;
        return AlertDialog(
          title: const Text('Pick a frame color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => selectedColor = color,
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsl,
              pickerAreaBorderRadius: const BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                onColorChanged(selectedColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> presetColors = [
      AppColors.textLight,
      AppColors.textDark,
      Colors.grey,
      Colors.brown,
      AppColors.secondary,
      AppColors.primary,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Re-upload Photo'),
            onPressed: onReUpload,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          title: 'Frame Aspect Ratio',
          value: selectedFrame,
          items: frameOptions,
          onChanged: onFrameChanged,
        ),
        const SizedBox(height: 16),
        const SectionTitle('Frame Color'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...presetColors.map((Color color) {
              return GestureDetector(
                onTap: () => onColorChanged(color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          frameColor == color
                              ? AppColors.primary
                              : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textDark.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: () => _showColorPickerDialog(context, frameColor),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        !presetColors.contains(frameColor)
                            ? AppColors.primary
                            : AppColors.border.withOpacity(0.5),
                    width: 2,
                  ),
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.yellow, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textDark.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.colorize,
                  color: AppColors.textLight.withOpacity(0.7),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SectionTitle('Photo Size'),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: photoSize,
                min: 1,
                max: photoSizeSteps.toDouble(),
                divisions: photoSizeSteps - 1,
                label: photoSize.round().toString(),
                onChanged: onPhotoSizeChanged,
              ),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                photoSize.round().toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          title: 'Export Quality',
          value: selectedQuality,
          items: qualityOptions,
          onChanged: onQualityChanged,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: onDownload,
            icon: const Icon(Icons.download),
            label: const Text('Download Framed Photo'),
          ),
        ),
      ],
    );
  }
}
