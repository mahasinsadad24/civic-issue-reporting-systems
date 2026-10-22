import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../styles/app_theme.dart';
import 'dart:io';

class ChatInputWidget extends StatefulWidget {
  final Function(String, List<String>) onSubmitted;

  const ChatInputWidget({
    super.key,
    required this.onSubmitted,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _attachments = [];
  bool _isComposing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleAttachment() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        _attachments.add(file.path);
      });
    }
  }

  void _handleSubmitted() {
    final text = _textController.text;
    if (text.trim().isEmpty && _attachments.isEmpty) return;

    widget.onSubmitted(text, List.from(_attachments));
    _textController.clear();
    setState(() {
      _attachments.clear();
      _isComposing = false;
    });
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_attachments.isNotEmpty)
          Container(
            height: 70,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _attachments.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.neutral200,
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_attachments[index]),
                          fit: BoxFit.cover,
                          width: 70,
                          height: 70,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeAttachment(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey[200]!,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded),
                    color: AppTheme.neutral600,
                    onPressed: _handleAttachment,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onChanged: (text) {
                        setState(() {
                          _isComposing = text.trim().isNotEmpty;
                        });
                      },
                      onSubmitted: (text) => _handleSubmitted(),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: const TextStyle(
                          color: AppTheme.neutral500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded),
                      color: _isComposing || _attachments.isNotEmpty
                          ? AppTheme.primaryColor
                          : AppTheme.neutral400,
                      onPressed: _isComposing || _attachments.isNotEmpty
                          ? _handleSubmitted
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
