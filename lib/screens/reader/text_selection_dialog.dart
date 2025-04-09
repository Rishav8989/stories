import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/reader_controller.dart';

class TextSelectionDialog extends StatelessWidget {
  final String selectedText;
  final int start;
  final int end;
  final String chapterId;
  final ReaderController controller;

  const TextSelectionDialog({
    Key? key,
    required this.selectedText,
    required this.start,
    required this.end,
    required this.chapterId,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Text Selection'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: const Text('Highlight'),
                onPressed: () {
                  controller.addHighlight(chapterId, selectedText, start, end);
                  Navigator.pop(context);
                },
              ),
              ActionChip(
                label: const Text('Add Note'),
                onPressed: () => _showAddNoteDialog(context),
              ),
              ActionChip(
                label: const Text('Dictionary'),
                onPressed: () => _showDictionaryDialog(context),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Enter your note...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.addNote(chapterId, noteController.text, start);
              Navigator.pop(context); // Close note dialog
              Navigator.pop(context); // Close selection dialog
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDictionaryDialog(BuildContext context) {
    // This is a placeholder for dictionary lookup
    // You would need to integrate with a dictionary API
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dictionary: $selectedText'),
        content: const Text('Dictionary lookup would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 