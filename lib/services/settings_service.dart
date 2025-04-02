import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsString = prefs.getString(_settingsKey);

    if (settingsString != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(settingsString);
        return AppSettings.fromJson(json);
      } catch (e) {
        print('Error decoding settings: $e');
        // Fallback to default settings if decoding fails
        return AppSettings();
      }
    } else {
      // Return default settings if nothing is saved yet
      return AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final String settingsString = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, settingsString);
  }
}
