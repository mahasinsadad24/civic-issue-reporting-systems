enum ChatAction {
  showReportForm,
  none,
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? attachments;
  final ChatAction action;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.attachments,
    this.action = ChatAction.none,
  });
}
