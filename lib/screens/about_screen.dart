import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // You can add more dynamic info here later (e.g., from pubspec.yaml)
    const appName = 'Framer';
    const appVersion = '1.0.0'; // Example version
    const appDescription = 'A simple app to add frames to your photos.';
    const author = 'Your Name/Company'; // Replace with your info
    const year = '2024'; // Current year

    return Scaffold(
      appBar: AppBar(
        title: const Text('About $appName'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.secondary),
            title: const Text('App Name'),
            subtitle: const Text(appName),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.new_releases_outlined,
              color: AppColors.secondary,
            ),
            title: const Text('Version'),
            subtitle: const Text(appVersion),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: AppColors.secondary,
            ),
            title: const Text('Description'),
            subtitle: const Text(appDescription),
            isThreeLine: true,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.copyright_outlined,
              color: AppColors.secondary,
            ),
            title: const Text('Copyright'),
            subtitle: Text('© $year $author'),
          ),
        ],
      ),
    );
  }
}
