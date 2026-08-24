// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/markdown_view.dart';
import '../../../../core/widgets/pdf_viewer.dart';
import '../../domain/entities/lesson.dart';
import '../controllers/course_detail_controller.dart';

/// Экран одного урока: Markdown-контент, материалы, отметка «пройдено».
/// Пушится с маршрута курса через ChangeNotifierProvider.value(controller).
class LessonPage extends StatelessWidget {
  final Lesson lesson;
  final int index; // 0-based
  const LessonPage({super.key, required this.lesson, required this.index});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ctrl = context.watch<CourseDetailController>();
    final done = ctrl.isLessonDone(lesson.id);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: Text('Урок ${index + 1}'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              Text(lesson.title,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: t.text)),
              const SizedBox(height: 16),
              if (lesson.content.trim().isEmpty)
                Text('Материал урока не заполнен.',
                    style: TextStyle(color: t.faint))
              else
                MarkdownView(lesson.content),
              if (lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _videoLink(context, lesson.videoUrl!),
              ],
              if (lesson.materials.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Материалы',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: t.muted,
                        fontSize: 14)),
                const SizedBox(height: 8),
                for (final m in lesson.materials) _materialLink(context, m),
              ],
              const SizedBox(height: 28),
              _completeBar(context, ctrl, done),
            ],
          ),
        ),
      ),
    );
  }

  Widget _completeBar(
      BuildContext context, CourseDetailController ctrl, bool done) {
    final t = context.tokens;
    if (done) {
      return Row(
        children: [
          Icon(Icons.check_circle, color: t.accent),
          const SizedBox(width: 8),
          Text('Урок пройден',
              style:
              TextStyle(color: t.accent, fontWeight: FontWeight.bold)),
          const Spacer(),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('К маршруту'),
          ),
        ],
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () async {
          await ctrl.completeLesson(lesson.id);
          if (context.mounted) Navigator.of(context).pop();
        },
        icon: const Icon(Icons.check),
        label: const Text('Отметить пройденным'),
      ),
    );
  }

  Widget _videoLink(BuildContext context, String url) {
    final t = context.tokens;
    return InkWell(
      onTap: () => html.window.open(url, '_blank'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Icon(Icons.ondemand_video, size: 18, color: t.accent),
          const SizedBox(width: 8),
          Flexible(
            child: Text(url,
                style: TextStyle(
                    color: t.accentInk,
                    decoration: TextDecoration.underline)),
          ),
        ]),
      ),
    );
  }

  Widget _materialLink(BuildContext context, LessonMaterial m) {
    final t = context.tokens;
    IconData icon;
    switch (m.type) {
      case 'pdf':
        icon = Icons.picture_as_pdf_outlined;
        break;
      case 'doc':
        icon = Icons.description_outlined;
        break;
      case 'video':
        icon = Icons.ondemand_video_outlined;
        break;
      case 'image':
        icon = Icons.image_outlined;
        break;
      default:
        icon = Icons.link;
    }
    return InkWell(
      onTap: () {
        if (m.file) {
          showPdfViewer(context,
              apiPath: m.url, title: m.title.isEmpty ? 'Документ' : m.title);
        } else {
          html.window.open(m.url, '_blank');
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: t.accent),
            const SizedBox(width: 8),
            Flexible(
              child: Text(m.title.isEmpty ? m.url : m.title,
                  style: TextStyle(
                      color: t.accentInk,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline)),
            ),
            const SizedBox(width: 4),
            Icon(m.file ? Icons.open_in_full : Icons.open_in_new,
                size: 14, color: t.faint),
          ],
        ),
      ),
    );
  }
}