import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../domain/entities/enrollment.dart';
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
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final it in ctrl.items) _tile(context, it)
          ],
        ),
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
    final enr = it.enrollment;
    final done = enr.status.isCompleted;
    return SizedBox(
      width: 340,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go('/courses/${it.course.id}'),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _badge(context, it.course.category, t.accentInk,
                        t.accentSoft),
                    const Spacer(),
                    if (enr.isMandatory)
                      _badge(context, 'Обязательный', t.amber, t.amberSoft),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 48,
                  child: Text(
                    it.course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.25,
                        color: t.text),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(done ? 'Завершён' : 'Прогресс',
                        style: TextStyle(
                            color: done ? t.success : t.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (done)
                      Icon(Icons.verified, color: t.success, size: 18)
                    else
                      Text('${enr.progress.toStringAsFixed(0)}%',
                          style: TextStyle(
                              color: t.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: enr.progress / 100,
                    minHeight: 8,
                    backgroundColor: t.ringTrack,
                    valueColor: AlwaysStoppedAnimation(t.success),
                  ),
                ),
                if (enr.dueDate != null && !done) ...[
                  const SizedBox(height: 12),
                  _deadline(context, enr),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _deadline(BuildContext context, Enrollment enr) {
    final t = context.tokens;
    final due = enr.dueDate!;
    final label = _fmtDate(due);
    if (enr.isOverdue) {
      return _badge(context, 'Просрочено · $label', t.danger, t.dangerSoft,
          icon: Icons.error_outline);
    }
    final left = enr.daysLeft ?? 0;
    final soon = left <= 3;
    return _badge(
      context,
      left == 0
          ? 'Сегодня дедлайн · $label'
          : 'Осталось $left ${_plural(left)} · до $label',
      soon ? t.danger : t.muted,
      soon ? t.dangerSoft : t.surface2,
      icon: Icons.schedule,
    );
  }

  Widget _badge(BuildContext context, String text, Color fg, Color bg,
      {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 5),
          ],
          Text(text,
              style: TextStyle(
                  color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static String _plural(int n) {
    final a = n.abs() % 100;
    final b = n.abs() % 10;
    if (a >= 11 && a <= 14) return 'дней';
    if (b == 1) return 'день';
    if (b >= 2 && b <= 4) return 'дня';
    return 'дней';
  }

  static String _fmtDate(DateTime d) {
    const m = [
      'янв', 'фев', 'мар', 'апр', 'мая', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}