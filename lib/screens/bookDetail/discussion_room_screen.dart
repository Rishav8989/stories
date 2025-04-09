import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/models/discussion_message.dart';
import 'package:stories/services/discussion_service.dart';

class DiscussionRoomScreen extends StatefulWidget {
  final String bookId;
  final String userId;

  const DiscussionRoomScreen({
    Key? key,
    required this.bookId,
    required this.userId,
  }) : super(key: key);

  @override
  State<DiscussionRoomScreen> createState() => _DiscussionRoomScreenState();
}

class _DiscussionRoomScreenState extends State<DiscussionRoomScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final DiscussionService _discussionService = DiscussionService();
  final List<DiscussionMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFirstTimeUser = true; // Assume first-time user for demonstration
  String? _discussionRules;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // Only one tab now
    _loadMessages();
    _loadDiscussionRules();
    _discussionService.subscribeToMessages(widget.bookId, _handleNewMessage);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  Future<void> _deleteMessage(String messageId) async {
    try {
      await _discussionService.deleteMessage(messageId);
      setState(() {
        _messages.removeWhere((msg) => msg.id == messageId);
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete message',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _confirmDeleteMessage(String messageId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _deleteMessage(messageId);
    }
  }

  Future<void> _loadDiscussionRules() async {
    try {
      final record = await _discussionService.getDiscussionRules(widget.bookId);
      setState(() {
        _discussionRules = record?.rules;
      });
    } catch (e) {
      print('Error loading discussion rules: $e');
    }
  }

  Future<void> _createOrUpdateDiscussionRules(String rules) async {
    try {
      await _discussionService.createOrUpdateDiscussionRules(widget.bookId, widget.userId, rules);
      setState(() {
        _discussionRules = rules;
      });
    } catch (e) {
      print('Error updating discussion rules: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion Room'),
      ),
      body: Column(
        children: [
          if (_isFirstTimeUser && _discussionRules != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discussion Room Rules',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(_discussionRules!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _isFirstTimeUser = false),
                    child: const Text('Got it!'),
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.userId == widget.userId;
                return GestureDetector(
                  onLongPress: isMe ? () => _confirmDeleteMessage(message.id) : null,
                  child: ChatMessage(
                    message: message,
                    isMe: isMe,
                    onDelete: null,
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final DiscussionMessage message;
  final bool isMe;
  final VoidCallback? onDelete;

  const ChatMessage({
    Key? key,
    required this.message,
    required this.isMe,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isMe ? colorScheme.primary : colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isMe ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      color: isMe ? colorScheme.onPrimary.withOpacity(0.7) : colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
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