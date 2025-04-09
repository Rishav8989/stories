import 'package:flutter/material.dart';

class ChatMessageActions extends StatelessWidget {
  final bool showDeleteButton;
  final bool isCurrentUser;
  final VoidCallback? onDelete;
  final ColorScheme colorScheme;

  const ChatMessageActions({
    Key? key,
    required this.showDeleteButton,
    required this.isCurrentUser,
    required this.onDelete,
    required this.colorScheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showDeleteButton || !isCurrentUser) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
        color: colorScheme.error,
        iconSize: 20,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
} 