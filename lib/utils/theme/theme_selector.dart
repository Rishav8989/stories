import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/utils/theme/theme_controller.dart';
import 'package:stories/screens/home screen/theme_selector_page.dart';

class ThemeSelectorWidget extends StatelessWidget {
  final ThemeController themeController = Get.find<ThemeController>();

  ThemeSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            leading: const Icon(Icons.palette, size: 32),
            title: Text(
              'Select Theme'.tr,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            onTap: () => Get.to(() => const ThemeSelectorPage()),
          ),
          const Divider(height: 1),
          _buildThemeListTile(
            context,
            'Light Reading'.tr,
            'Optimized for daytime reading'.tr,
            Icons.light_mode,
            themeController.switchToLightReadingTheme,
          ),
          _buildThemeListTile(
            context,
            'Sepia'.tr,
            'Warm, eye-friendly reading mode'.tr,
            Icons.filter_vintage,
            themeController.switchToSepiaTheme,
          ),
          _buildThemeListTile(
            context,
            'Dark Reading'.tr,
            'Optimized for nighttime reading'.tr,
            Icons.dark_mode,
            themeController.switchToDarkReadingTheme,
          ),
          _buildThemeListTile(
            context,
            'AMOLED Dark'.tr,
            'True black for AMOLED screens'.tr,
            Icons.brightness_2,
            themeController.switchToAmoledDarkTheme,
          ),
          _buildThemeListTile(
            context,
            'High Contrast'.tr,
            'Enhanced readability'.tr,
            Icons.contrast,
            themeController.switchToHighContrastTheme,
          ),
          _buildThemeListTile(
            context,
            'Paper White'.tr,
            'Natural paper-like reading experience'.tr,
            Icons.description,
            themeController.switchToPaperWhiteTheme,
          ),
          _buildThemeListTile(
            context,
            'Night Light'.tr,
            'Reduced blue light for night reading'.tr,
            Icons.nightlight_round,
            themeController.switchToNightLightTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeListTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Function() onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      leading: Icon(icon, size: 24),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: onTap,
    );
  }
}