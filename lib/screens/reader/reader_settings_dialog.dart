import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/reader_controller.dart';

class ReaderSettingsDialog extends StatelessWidget {
  final ReaderController controller;

  const ReaderSettingsDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Reading Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
              children: [
                _buildSettingItem(
                  'Font Size',
                  Slider(
                    value: controller.fontSize.value,
                    min: 12,
                    max: 24,
                    divisions: 12,
                    label: '${controller.fontSize.value.round()}',
                    onChanged: (value) {
                      controller.fontSize.value = value;
                      controller.saveSettings();
                    },
                  ),
                ),
                _buildSettingItem(
                  'Line Spacing',
                  Slider(
                    value: controller.lineSpacing.value,
                    min: 1.0,
                    max: 2.5,
                    divisions: 15,
                    label: controller.lineSpacing.value.toStringAsFixed(1),
                    onChanged: (value) {
                      controller.lineSpacing.value = value;
                      controller.saveSettings();
                    },
                  ),
                ),
                _buildSettingItem(
                  'Paragraph Spacing',
                  Slider(
                    value: controller.paragraphSpacing.value,
                    min: 8,
                    max: 32,
                    divisions: 12,
                    label: '${controller.paragraphSpacing.value.round()}',
                    onChanged: (value) {
                      controller.paragraphSpacing.value = value;
                      controller.saveSettings();
                    },
                  ),
                ),
              ],
            )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, Widget control) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 8),
          control,
        ],
      ),
    );
  }
} 