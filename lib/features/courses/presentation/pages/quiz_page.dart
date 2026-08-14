import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/quiz.dart';
import '../controllers/quiz_controller.dart';

/// Полноэкранное прохождение теста. Возвращает true, если сдан.
class QuizPage extends StatelessWidget {
  final int courseId;
  final String courseTitle;
  const QuizPage({super.key, required this.courseId, required this.courseTitle});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<QuizController>()..load(courseId),
      child: _QuizView(courseId: courseId, courseTitle: courseTitle),
    );
  }
}

class _QuizView extends StatelessWidget {
  final int courseId;
  final String courseTitle;
  const _QuizView({required this.courseId, required this.courseTitle});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<QuizController>();
    return Scaffold(
      appBar: AppBar(title: Text('Тест: $courseTitle')),
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.error != null && ctrl.result == null
          ? Center(child: Text('Ошибка: ${ctrl.error}'))
          : ctrl.result != null
          ? _Result(courseId: courseId)
          : _Questions(courseId: courseId),
    );
  }
}

class _Questions extends StatelessWidget {
  final int courseId;
  const _Questions({required this.courseId});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<QuizController>();
    final questions = ctrl.quiz!.questions;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            for (var i = 0; i < questions.length; i++)
              _questionCard(context, i + 1, questions[i], ctrl),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: ctrl.submitting
                  ? null
                  : () {
                if (!ctrl.allAnswered) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ответьте на все вопросы')),
                  );
                  return;
                }
                ctrl.submit(courseId);
              },
              icon: ctrl.submitting
                  ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check),
              label: const Text('Завершить тест'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _questionCard(
      BuildContext context, int num, Question q, QuizController ctrl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$num. ${q.text}',
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (final a in q.answers)
              RadioListTile<int>(
                value: a.id,
                groupValue: ctrl.selected[q.id],
                onChanged: (v) => ctrl.select(q.id, v!),
                title: Text(a.text),
                activeColor: AppColors.brand,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  final int courseId;
  const _Result({required this.courseId});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<QuizController>();
    final r = ctrl.result!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(r.passed ? Icons.verified : Icons.cancel,
                    size: 72,
                    color: r.passed ? AppColors.brand : Colors.redAccent),
                const SizedBox(height: 16),
                Text(r.passed ? 'Тест сдан!' : 'Тест не сдан',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: r.passed ? AppColors.brand : Colors.redAccent)),
                const SizedBox(height: 8),
                Text('Результат: ${r.score.toStringAsFixed(0)}%  '
                    '(${r.correct} из ${r.total})'),
                const SizedBox(height: 8),
                if (r.passed && r.certificateId != null)
                  const Text('🎓 Сертификат выдан — см. раздел «Сертификаты»',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                if (!r.passed)
                  const Text('Повторите материал и попробуйте ещё раз.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!r.passed)
                      OutlinedButton(
                        onPressed: ctrl.reset,
                        child: const Text('Пройти заново'),
                      ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(r.passed),
                      child: const Text('Готово'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
