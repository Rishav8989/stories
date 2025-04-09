import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  final VoidCallback? onDelete;
  final String? senderAvatarUrl;

  const ChatMessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.onDelete,
    this.senderAvatarUrl,
  }) : super(key: key);

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  bool _showDeleteIcon = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showDeleteIcon) {
          setState(() {
            _showDeleteIcon = false;
          });
        }
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: widget.isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: widget.isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (!widget.isCurrentUser) ...[
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: widget.senderAvatarUrl != null
                          ? NetworkImage(widget.senderAvatarUrl!)
                          : null,
                      child: widget.senderAvatarUrl == null
                          ? Text(widget.message.senderName[0].toUpperCase())
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.message.senderName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                  if (widget.isCurrentUser) ...[
                    Text(
                      'You',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisAlignment: widget.isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isCurrentUser && _showDeleteIcon) ...[
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Message'),
                          content: Text('Are you sure you want to delete this message from ${widget.message.senderName}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onDelete?.call();
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                ],
                GestureDetector(
                  onTap: widget.isCurrentUser ? () {
                    setState(() {
                      _showDeleteIcon = true;
                    });
                  } : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.isCurrentUser
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message.content,
                          style: TextStyle(
                            color: widget.isCurrentUser ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(widget.message.timestamp),
                          style: TextStyle(
                            color: widget.isCurrentUser ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
} 