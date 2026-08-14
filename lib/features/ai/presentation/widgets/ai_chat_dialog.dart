import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/repositories/ai_repository.dart';

/// Диалог AI-ассистента по материалам курса.
class AiChatDialog extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  final AiRepository repository;

  const AiChatDialog({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.repository,
  });

  @override
  State<AiChatDialog> createState() => _AiChatDialogState();
}

class _AiChatDialogState extends State<AiChatDialog> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _busy = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _busy = true;
      _controller.clear();
    });
    _scrollDown();
    try {
      final history = _messages
          .sublist(0, _messages.length - 1)
          .map((m) => {'role': m['role']!, 'content': m['content']!})
          .toList();
      final reply = await widget.repository.chat(widget.courseId, text, history);
      setState(() => _messages.add({'role': 'assistant', 'content': reply}));
    } catch (e) {
      setState(() =>
          _messages.add({'role': 'assistant', 'content': '⚠️ ${e.toString()}'}));
    } finally {
      setState(() => _busy = false);
      _scrollDown();
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 520,
        height: 600,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.brand,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_outlined, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI-ассистент',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(widget.courseTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Задайте вопрос по материалам курса —\nассистент ответит на основе лекций.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
                  : ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (c, i) => _bubble(_messages[i]),
              ),
            ),
            if (_busy) const LinearProgressIndicator(minHeight: 2),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                          hintText: 'Ваш вопрос…', isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _busy ? null : _send,
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(backgroundColor: AppColors.brand),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(Map<String, String> m) {
    final isUser = m['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: isUser ? AppColors.brand : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(m['content'] ?? '',
            style: TextStyle(color: isUser ? Colors.white : Colors.black87)),
      ),
    );
  }
}
