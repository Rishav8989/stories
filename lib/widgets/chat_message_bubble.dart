import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import 'chat/chat_message_reply.dart';
import 'chat/chat_message_content.dart';
import 'chat/chat_message_actions.dart';

class ChatMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;
  final String? senderAvatarUrl;
  final String formattedTime;
  final Function(String messageId)? onReplyTap;
  final bool isHighlighted;

  const ChatMessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.onDelete,
    this.onReply,
    this.senderAvatarUrl,
    required this.formattedTime,
    this.onReplyTap,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> with SingleTickerProviderStateMixin {
  bool _showDeleteButton = false;
  late final AnimationController _highlightController;
  late final Animation<double> _highlightAnimation;

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _highlightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _highlightController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key(widget.message.id),
      direction: DismissDirection.horizontal,
      background: Container(
        color: colorScheme.primary.withOpacity(0.1),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Icon(Icons.reply),
          ),
        ),
      ),
      secondaryBackground: Container(
        color: colorScheme.primary.withOpacity(0.1),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.reply),
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        widget.onReply?.call();
        return false;
      },
      child: GestureDetector(
        onLongPress: () {
          if (widget.isCurrentUser) {
            setState(() {
              _showDeleteButton = true;
            });
          }
        },
        onTap: () {
          if (_showDeleteButton) {
            setState(() {
              _showDeleteButton = false;
            });
          }
        },
        child: Align(
          alignment: widget.isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChatMessageActions(
                  showDeleteButton: _showDeleteButton,
                  isCurrentUser: widget.isCurrentUser,
                  onDelete: () {
                    widget.onDelete?.call();
                    setState(() {
                      _showDeleteButton = false;
                    });
                  },
                  colorScheme: colorScheme,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: widget.isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (widget.message.replyTo != null)
                        ChatMessageReply(
                          replyToUserName: widget.message.replyToUserName,
                          replyToMessage: widget.message.replyToMessage,
                          onReplyTap: () {
                            if (widget.onReplyTap != null && widget.message.replyTo != null) {
                              widget.onReplyTap!(widget.message.replyTo!);
                            }
                          },
                          colorScheme: colorScheme,
                          theme: theme,
                        ),
                      ChatMessageContent(
                        content: widget.message.content,
                        senderName: widget.message.senderName,
                        formattedTime: widget.formattedTime,
                        isCurrentUser: widget.isCurrentUser,
                        colorScheme: colorScheme,
                        theme: theme,
                        highlightAnimation: _highlightAnimation,
                        isHighlighted: widget.isHighlighted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 