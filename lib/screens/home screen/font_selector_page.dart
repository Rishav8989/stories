import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/font_controller.dart';

class FontSelectorPage extends StatelessWidget {
  const FontSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fontController = Get.find<FontController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Font'.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFontListTile(
              context,
              'Merriweather',
              'Classic serif for comfortable reading',
              fontController.switchToMerriweather,
              fontController.selectedFont.value == 'Merriweather',
            ),
            _buildFontListTile(
              context,
              'Dancing Script',
              'Elegant handwritten style',
              fontController.switchToDancingScript,
              fontController.selectedFont.value == 'Dancing Script',
            ),
            _buildFontListTile(
              context,
              'Pacifico',
              'Casual handwritten style',
              fontController.switchToPacifico,
              fontController.selectedFont.value == 'Pacifico',
            ),
            _buildFontListTile(
              context,
              'Caveat',
              'Natural handwriting style',
              fontController.switchToCaveat,
              fontController.selectedFont.value == 'Caveat',
            ),
            _buildFontListTile(
              context,
              'Roboto Mono',
              'Clean monospace for technical content',
              fontController.switchToRobotoMono,
              fontController.selectedFont.value == 'Roboto Mono',
            ),
            _buildFontListTile(
              context,
              'Source Code Pro',
              'Professional monospace font',
              fontController.switchToSourceCodePro,
              fontController.selectedFont.value == 'Source Code Pro',
            ),
            _buildFontListTile(
              context,
              'Playfair Display',
              'Elegant serif for headings',
              fontController.switchToPlayfairDisplay,
              fontController.selectedFont.value == 'Playfair Display',
            ),
            _buildFontListTile(
              context,
              'Cormorant',
              'Stylish serif with character',
              fontController.switchToCormorant,
              fontController.selectedFont.value == 'Cormorant',
            ),
            _buildFontListTile(
              context,
              'Alegreya',
              'Elegant serif with personality',
              fontController.switchToAlegreya,
              fontController.selectedFont.value == 'Alegreya',
            ),
            _buildFontListTile(
              context,
              'Lora',
              'Classic serif with modern touch',
              fontController.switchToLora,
              fontController.selectedFont.value == 'Lora',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontListTile(
    BuildContext context,
    String title,
    String subtitle,
    Function() onTap,
    bool isSelected,
  ) {
    final fontController = Get.find<FontController>();
    
    return Obx(() {
      final isLoading = fontController.isLoading.value && isSelected;
      
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          leading: isLoading 
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                isSelected ? Icons.check_circle : Icons.font_download,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: title,
            ),
          ),
          subtitle: Text(subtitle),
          onTap: isLoading ? null : () async {
            await onTap();
          },
        ),
      );
    });
  }
} 