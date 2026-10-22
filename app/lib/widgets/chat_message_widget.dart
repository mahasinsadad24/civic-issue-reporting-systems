import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../styles/app_theme.dart';
import 'package:intl/intl.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final Function(ChatAction) onActionTap;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              radius: 16,
              child: Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppTheme.primaryColor
                        : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: message.isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser
                              ? Colors.white
                              : AppTheme.neutral800,
                          fontSize: 14,
                        ),
                      ),
                      if (message.attachments != null &&
                          message.attachments!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: message.attachments!.map((attachment) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: message.isUser
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getAttachmentIcon(attachment),
                                    size: 16,
                                    color: message.isUser
                                        ? Colors.white
                                        : AppTheme.neutral600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getAttachmentName(attachment),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: message.isUser
                                          ? Colors.white
                                          : AppTheme.neutral600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      if (message.action != ChatAction.none) ...[
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => onActionTap(message.action),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Submit Report'),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('h:mm a').format(message.timestamp),
                    style: const TextStyle(
                      color: AppTheme.neutral500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundColor: AppTheme.neutral200,
              radius: 16,
              child: Icon(
                Icons.person_rounded,
                color: AppTheme.neutral600,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getAttachmentIcon(String attachment) {
    if (attachment.toLowerCase().endsWith('.jpg') ||
        attachment.toLowerCase().endsWith('.png')) {
      return Icons.image_rounded;
    } else if (attachment.toLowerCase().endsWith('.mp4')) {
      return Icons.video_file_rounded;
    } else if (attachment.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    }
    return Icons.attach_file_rounded;
  }

  String _getAttachmentName(String attachment) {
    final name = attachment.split('/').last;
    if (name.length > 15) {
      return '${name.substring(0, 12)}...';
    }
    return name;
  }
}
