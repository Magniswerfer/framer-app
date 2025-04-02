import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import '../models/app_settings.dart';
import '../services/settings_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_dropdown.dart'; // Re-use dropdown
import '../widgets/section_title.dart'; // Re-use section title

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  late Future<AppSettings> _settingsFuture;
  AppSettings? _currentSettings;
  bool _isLoading = true;

  // Controllers for text fields
  late TextEditingController _stepsController;
  late TextEditingController _minSizeController;
  late TextEditingController _maxSizeController;
  late TextEditingController _defaultStepController;

  @override
  void initState() {
    super.initState();
    _settingsFuture = _loadSettings();
    _stepsController = TextEditingController();
    _minSizeController = TextEditingController();
    _maxSizeController = TextEditingController();
    _defaultStepController = TextEditingController();
  }

  Future<AppSettings> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    final settings = await _settingsService.loadSettings();
    _currentSettings = settings;
    // Initialize controllers with loaded values
    _stepsController.text = settings.photoSizeSteps.toString();
    _minSizeController.text = (settings.minPhotoSizePercent * 100)
        .toStringAsFixed(0);
    _maxSizeController.text = (settings.maxPhotoSizePercent * 100)
        .toStringAsFixed(0);
    _defaultStepController.text = settings.defaultPhotoSizeStep.toString();
    setState(() {
      _isLoading = false;
    });
    return settings;
  }

  @override
  void dispose() {
    // Dispose controllers
    _stepsController.dispose();
    _minSizeController.dispose();
    _maxSizeController.dispose();
    _defaultStepController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (_currentSettings == null) return;

    // Validate and parse values from controllers
    final int steps =
        int.tryParse(_stepsController.text) ?? _currentSettings!.photoSizeSteps;
    final double minPercent =
        (double.tryParse(_minSizeController.text) ??
            (_currentSettings!.minPhotoSizePercent * 100)) /
        100.0;
    final double maxPercent =
        (double.tryParse(_maxSizeController.text) ??
            (_currentSettings!.maxPhotoSizePercent * 100)) /
        100.0;
    final int defaultStep =
        int.tryParse(_defaultStepController.text) ??
        _currentSettings!.defaultPhotoSizeStep;

    // Create updated settings object
    final updatedSettings = _currentSettings!.copyWith(
      photoSizeSteps: steps.clamp(2, 50), // Basic validation
      minPhotoSizePercent: minPercent.clamp(0.01, 0.99),
      maxPhotoSizePercent: maxPercent.clamp(
        minPercent + 0.01,
        1.0,
      ), // Ensure max > min
      defaultPhotoSizeStep: defaultStep.clamp(
        1,
        steps,
      ), // Clamp based on actual steps
      // defaultAspectRatio is handled by the dropdown
    );

    await _settingsService.saveSettings(updatedSettings);
    setState(() {
      _currentSettings = updatedSettings;
      // Refresh future to reflect saved state (optional, might reload)
      _settingsFuture = Future.value(updatedSettings);
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings Saved!')));
      // Optionally pop back after saving
      // Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Settings',
            onPressed: _currentSettings != null ? _saveSettings : null,
          ),
        ],
      ),
      body: FutureBuilder<AppSettings>(
        future: _settingsFuture,
        builder: (context, snapshot) {
          if (_isLoading || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading settings: ${snapshot.error}'),
            );
          }

          final settings =
              _currentSettings!; // Use the state variable after loading

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SectionTitle('Photo Size Slider'),
              _buildTextField(
                controller: _stepsController,
                label: 'Number of Steps (2-50)',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _minSizeController,
                label: 'Min Size (% of Frame)',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                suffix: '%',
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _maxSizeController,
                label: 'Max Size (% of Frame)',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                suffix: '%',
              ),
              const SizedBox(height: 24),

              const SectionTitle('Defaults'),
              _buildTextField(
                controller: _defaultStepController,
                label: 'Default Size Step (1-${settings.photoSizeSteps})',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 10),
              CustomDropdown<String>(
                title: 'Default Aspect Ratio',
                value: settings.defaultAspectRatio,
                items: AppConstants.frameOptions,
                onChanged: (String? newValue) {
                  if (newValue != null && _currentSettings != null) {
                    setState(() {
                      _currentSettings = _currentSettings!.copyWith(
                        defaultAspectRatio: newValue,
                      );
                      // Note: We save all settings together via the save button
                    });
                  }
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _currentSettings != null ? _saveSettings : null,
                  child: const Text('Save Settings'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixText: suffix,
        isDense: true,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }
}
