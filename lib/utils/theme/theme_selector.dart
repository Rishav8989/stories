import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/utils/theme/theme_controller.dart';

class ThemeSelectorWidget extends StatelessWidget {
  final ThemeController themeController;
  final RxBool showThemeOptions = false.obs;

  ThemeSelectorWidget({
    Key? key,
    required this.themeController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          _buildThemeListTile(context),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: showThemeOptions.value
                ? _buildThemeOptionsCard(context)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeListTile(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        leading: Icon(
          themeController.currentTheme == AppTheme.light
              ? Icons.light_mode
              : Icons.dark_mode,
          size: 32,
          color: Theme.of(context).iconTheme.color,
        ),
        title: Text(
          '${'Theme'.tr}: ${themeController.currentTheme.name.capitalize}',
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onTap: () => showThemeOptions.toggle(),
      ),
    );
  }

  Widget _buildThemeOptionsCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            context: context,
            icon: Icons.light_mode,
            text: 'Light Mode',
            isSelected: themeController.currentTheme == AppTheme.light,
            onTap: () {
              themeController.switchToLightTheme();
              showThemeOptions.value = false;
              Get.forceAppUpdate();
            },
          ),
          _buildThemeOption(
            context: context,
            icon: Icons.dark_mode,
            text: 'Dark Mode',
            isSelected: themeController.currentTheme == AppTheme.dark,
            onTap: () {
              themeController.switchToDarkTheme();
              showThemeOptions.value = false;
              Get.forceAppUpdate();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required IconData icon,
    required String text,
    required bool isSelected,
    required Function() onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue : Theme.of(context).iconTheme.color,
        size: 28,
      ),
      title: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.blue
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
      ),
      onTap: onTap,
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.blue, size: 24)
          : const SizedBox.shrink(),
    );
  }
}