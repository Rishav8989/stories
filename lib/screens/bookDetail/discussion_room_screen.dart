import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/models/chat_message.dart';
import 'package:stories/models/discussion_message.dart';
import 'package:stories/services/discussion_service.dart';
import 'package:stories/widgets/chat_message_bubble.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

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
  bool _isFirstTimeUser = true;
  String? _discussionRules;
  late final BookDetailsController _bookController;
  final DateFormat _timeFormat = DateFormat('h:mm a');
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  late final tz.Location _localLocation;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _localLocation = tz.local;
    _tabController = TabController(length: 1, vsync: this);
    _bookController = Get.find<BookDetailsController>(tag: widget.bookId);
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

  DateTime _convertToLocalTime(DateTime utcTime) {
    // Ensure the input time is treated as UTC
    final utcDateTime = DateTime.utc(
      utcTime.year,
      utcTime.month,
      utcTime.day,
      utcTime.hour,
      utcTime.minute,
      utcTime.second,
      utcTime.millisecond,
      utcTime.microsecond,
    );
    // Convert to local time
    return utcDateTime.toLocal();
  }

  String _formatMessageTime(DateTime utcTime) {
    final localTime = _convertToLocalTime(utcTime);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(localTime.year, localTime.month, localTime.day);

    if (messageDate == today) {
      return _timeFormat.format(localTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${_timeFormat.format(localTime)}';
    } else {
      return '${_dateFormat.format(localTime)} ${_timeFormat.format(localTime)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          _bookController.book.value?.title ?? 'Discussion Room',
          style: theme.textTheme.titleLarge,
        )),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.05),
              colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
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
                        
                        final chatMessage = ChatMessage(
                          id: message.id,
                          senderId: message.userId,
                          senderName: message.userName,
                          content: message.message,
                          timestamp: message.createdAt,
                        );

                        return ChatMessageBubble(
                          message: chatMessage,
                          isCurrentUser: isMe,
                          onDelete: isMe ? () => _deleteMessage(message.id) : null,
                          senderAvatarUrl: message.userAvatar,
                          formattedTime: _formatMessageTime(message.createdAt),
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
            ),
          ),
        ),
      ),
    );
  }
} 