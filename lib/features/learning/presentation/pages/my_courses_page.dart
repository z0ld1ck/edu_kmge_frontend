import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../domain/entities/my_course.dart';
import '../controllers/my_courses_controller.dart';

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<MyCoursesController>()..load(),
      child: const _MyCoursesView(),
    );
  }
}

class _MyCoursesView extends StatelessWidget {
  const _MyCoursesView();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<MyCoursesController>();
    return AppShell(
      title: 'Мои курсы',
      current: '/my',
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.error != null
          ? Center(child: Text('Ошибка: ${ctrl.error}'))
          : ctrl.items.isEmpty
          ? _empty(context)
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [for (final it in ctrl.items) _tile(context, it)],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, size: 64, color: t.faint),
          const SizedBox(height: 12),
          const Text('Вы ещё не записаны ни на один курс'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go('/catalog'),
            child: const Text('Перейти в каталог'),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, MyCourse it) {
    final t = context.tokens;
    final done = it.enrollment.status.isCompleted;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: () => context.go('/courses/${it.course.id}'),
        title: Text(it.course.title,
            style: TextStyle(fontWeight: FontWeight.bold, color: t.text)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(it.course.category,
                  style: TextStyle(color: t.muted, fontSize: 12)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: it.enrollment.progress / 100,
                  minHeight: 8,
                  backgroundColor: t.ringTrack,
                  valueColor: AlwaysStoppedAnimation(t.accent),
                ),
              ),
            ],
          ),
        ),
        trailing: done
            ? Chip(
          avatar: Icon(Icons.verified, color: t.accent, size: 18),
          label: const Text('Завершён'),
        )
            : Text('${it.enrollment.progress.toStringAsFixed(0)}%',
            style: TextStyle(
                color: t.accent,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
  }
}