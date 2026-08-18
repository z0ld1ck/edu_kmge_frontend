import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../ai/domain/repositories/ai_repository.dart';
import '../../../ai/presentation/widgets/ai_chat_dialog.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/lesson.dart';
import '../controllers/course_detail_controller.dart';
import 'quiz_page.dart';

class CourseDetailPage extends StatelessWidget {
  final int courseId;
  const CourseDetailPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<CourseDetailController>()..load(courseId),
      child: _CourseDetailView(courseId: courseId),
    );
  }
}

class _CourseDetailView extends StatelessWidget {
  final int courseId;
  const _CourseDetailView({required this.courseId});

  Future<void> _openQuiz(BuildContext context, String title) async {
    final ctrl = context.read<CourseDetailController>();
    final passed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => QuizPage(courseId: courseId, courseTitle: title),
      ),
    );
    if (passed == true) ctrl.load(courseId);
  }

  void _openAi(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (_) => AiChatDialog(
        courseId: courseId,
        courseTitle: title,
        repository: sl<AiRepository>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CourseDetailController>();
    final isStaff = context.read<AuthController>().user?.isStaff ?? false;
    final course = ctrl.course;

    return AppShell(
      title: course?.title ?? 'Курс',
      current: '/catalog',
      actions: [
        if (ctrl.aiEnabled && course != null)
          IconButton(
            tooltip: 'AI-ассистент',
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: () => _openAi(context, course.title),
          ),
        if (isStaff && course != null)
          IconButton(
            tooltip: 'Редактировать',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/admin/courses/$courseId'),
          ),
      ],
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.error != null
          ? Center(child: Text('Ошибка: ${ctrl.error}'))
          : _content(context, ctrl),
    );
  }

  Widget _content(BuildContext context, CourseDetailController ctrl) {
    final t = context.tokens;
    final course = ctrl.course!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: t.accentSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(course.category,
                    style: TextStyle(
                        color: t.accentInk, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              Text(course.title,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: t.text)),
              const SizedBox(height: 10),
              Text(course.description,
                  style: TextStyle(color: t.muted, fontSize: 15)),
              const SizedBox(height: 20),
              if (!ctrl.enrolled)
                FilledButton.icon(
                  onPressed: () => ctrl.enroll(courseId),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Записаться на курс'),
                )
              else ...[
                _progressBar(context, ctrl.doneLessons, ctrl.totalLessons),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 8),
              Text('Программа курса',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: t.text)),
              const SizedBox(height: 12),
              for (var i = 0; i < course.lessons.length; i++)
                _lessonTile(context, ctrl, i + 1, course.lessons[i]),
              if (course.hasQuiz) ...[
                const SizedBox(height: 20),
                _quizCard(context, ctrl, course.title),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar(BuildContext context, int done, int total) {
    final t = context.tokens;
    final pct = total == 0 ? 0.0 : done / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Прогресс: $done из $total уроков',
                style: TextStyle(fontWeight: FontWeight.w600, color: t.text)),
            const Spacer(),
            Text('${(pct * 100).toStringAsFixed(0)}%',
                style: TextStyle(color: t.accent, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 10,
            backgroundColor: t.ringTrack,
            valueColor: AlwaysStoppedAnimation(t.accent),
          ),
        ),
      ],
    );
  }

  Widget _lessonTile(
      BuildContext context, CourseDetailController ctrl, int num, Lesson lesson) {
    final t = context.tokens;
    final completed = ctrl.completedLessonIds.contains(lesson.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: CircleAvatar(
          backgroundColor: completed ? t.accent : t.surface2,
          child: completed
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : Text('$num', style: TextStyle(color: t.muted)),
        ),
        title: Text(lesson.title,
            style: TextStyle(fontWeight: FontWeight.w600, color: t.text)),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lesson.content,
              style: TextStyle(fontSize: 15, height: 1.5, color: t.text)),
          if (lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.ondemand_video, size: 18, color: t.accent),
              const SizedBox(width: 6),
              Expanded(child: SelectableText(lesson.videoUrl!)),
            ]),
          ],
          const SizedBox(height: 12),
          if (ctrl.enrolled)
            Align(
              alignment: Alignment.centerRight,
              child: completed
                  ? Chip(
                avatar: Icon(Icons.check_circle, color: t.accent, size: 18),
                label: const Text('Пройдено'),
              )
                  : FilledButton.tonal(
                onPressed: () => ctrl.completeLesson(lesson.id),
                child: const Text('Отметить пройденным'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _quizCard(
      BuildContext context, CourseDetailController ctrl, String title) {
    final t = context.tokens;
    final canTake = ctrl.enrolled && ctrl.allLessonsDone;
    return Card(
      color: t.accentSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: t.accent.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.quiz_outlined, color: t.accent, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Итоговый тест',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: t.text)),
                  Text(
                    ctrl.enrolled
                        ? (ctrl.allLessonsDone
                        ? 'Все уроки пройдены — можно сдавать тест'
                        : 'Сначала пройдите все уроки')
                        : 'Запишитесь на курс, чтобы пройти тест',
                    style: TextStyle(color: t.muted),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: canTake ? () => _openQuiz(context, title) : null,
              child: const Text('Пройти тест'),
            ),
          ],
        ),
      ),
    );
  }
}