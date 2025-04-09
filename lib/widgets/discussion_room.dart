import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/discussion_message.dart';
import '../services/discussion_service.dart';

class DiscussionRoom extends StatefulWidget {
  final String bookId;
  final String userId;

  const DiscussionRoom({
    Key? key,
    required this.bookId,
    required this.userId,
  }) : super(key: key);

  @override
  State<DiscussionRoom> createState() => _DiscussionRoomState();
}

class _DiscussionRoomState extends State<DiscussionRoom> {
  final DiscussionService _discussionService = DiscussionService();
  final TextEditingController _messageController = TextEditingController();
  final List<DiscussionMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _discussionService.subscribeToMessages(widget.bookId, _handleNewMessage);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _discussionService.unsubscribe();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final messages = await _discussionService.getMessages(widget.bookId);
    setState(() {
      _messages.addAll(messages);
    });
    _scrollToBottom();
  }

  void _handleNewMessage(DiscussionMessage message) {
    setState(() {
      _messages.insert(0, message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _discussionService.sendMessage(
        widget.userId,
        widget.bookId,
        _messageController.text.trim(),
      );
      _messageController.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return MessageBubble(
                message: message,
                isMe: message.userId == widget.userId,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MessageBubble extends StatelessWidget {
  final DiscussionMessage message;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
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