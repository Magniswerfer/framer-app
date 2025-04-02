import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// Define enum for menu actions
enum MenuAction { settings, about }

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  // Remove onMenuPressed
  // final VoidCallback onMenuPressed;

  // Add callbacks for actions
  final VoidCallback onSettingsPressed;
  final VoidCallback onAboutPressed;

  const AppHeader({
    // required this.onMenuPressed, // Remove
    required this.onSettingsPressed,
    required this.onAboutPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Don't show back button or drawer icon
      title: const Text(
        'framer',
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.textLight,
      elevation: 0,
      actions: [
        PopupMenuButton<MenuAction>(
          icon: const Icon(
            Icons.menu,
            color: AppColors.textLight,
          ), // Use menu icon
          onSelected: (MenuAction result) {
            switch (result) {
              case MenuAction.settings:
                onSettingsPressed();
                break;
              case MenuAction.about:
                onAboutPressed();
                break;
            }
          },
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<MenuAction>>[
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.settings,
                  child: ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text('Settings'),
                  ),
                ),
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.about,
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('About'),
                  ),
                ),
              ],
        ),
      ],
    );
  }

  @override
  // Keep preferredSize or adjust if needed based on AppBar usage
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
