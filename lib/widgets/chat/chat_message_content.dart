import 'package:flutter/material.dart';

class ChatMessageContent extends StatelessWidget {
  final String content;
  final String senderName;
  final String formattedTime;
  final bool isCurrentUser;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final Animation<double> highlightAnimation;
  final bool isHighlighted;

  const ChatMessageContent({
    Key? key,
    required this.content,
    required this.senderName,
    required this.formattedTime,
    required this.isCurrentUser,
    required this.colorScheme,
    required this.theme,
    required this.highlightAnimation,
    required this.isHighlighted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: highlightAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isHighlighted
                ? Color.lerp(
                    isCurrentUser
                        ? colorScheme.primary.withOpacity(0.9)
                        : colorScheme.surfaceVariant,
                    colorScheme.primary.withOpacity(0.3),
                    highlightAnimation.value,
                  )
                : isCurrentUser
                    ? colorScheme.primary.withOpacity(0.9)
                    : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isCurrentUser ? 16 : 4),
              topRight: Radius.circular(isCurrentUser ? 4 : 16),
              bottomLeft: const Radius.circular(16),
              bottomRight: const Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        );
      },
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Text(
                senderName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (!isCurrentUser)
              const SizedBox(height: 4),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isCurrentUser 
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                formattedTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isCurrentUser 
                      ? colorScheme.onPrimary.withOpacity(0.7)
                      : colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 