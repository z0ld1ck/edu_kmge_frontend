import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../domain/entities/analytics.dart';
import '../controllers/dashboard_controller.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<DashboardController>()..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final ctrl = context.read<DashboardController>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Удалить курс?'),
        content:
        const Text('Действие необратимо, все данные курса будут удалены.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Отмена')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Удалить')),
        ],
      ),
    );
    if (ok == true) ctrl.deleteCourse(id);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DashboardController>();
    return AppShell(
      title: 'Панель управления',
      current: '/admin',
      actions: [
        IconButton(
          tooltip: 'Экспорт в Excel',
          icon: const Icon(Icons.file_download_outlined),
          onPressed: () => ctrl.exportUsers(),
        ),
      ],
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.error != null
          ? Center(child: Text('Ошибка: ${ctrl.error}'))
          : RefreshIndicator(
        onRefresh: ctrl.load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _statsRow(ctrl.overview!),
            const SizedBox(height: 28),
            _coursesHeader(context),
            const SizedBox(height: 12),
            _coursesTable(context, ctrl),
          ],
        ),
      ),
    );
  }

  Widget _statsRow(OverviewStats o) {
    final cards = [
      _StatCard('Пользователей', '${o.totalUsers}', Icons.people_outline),
      _StatCard('Курсов', '${o.totalCourses}', Icons.school_outlined),
      _StatCard('Записей на курсы', '${o.totalEnrollments}',
          Icons.how_to_reg_outlined),
      _StatCard('Завершено', '${o.completedEnrollments}', Icons.task_alt_outlined),
      _StatCard('Сертификатов', '${o.certificatesIssued}',
          Icons.workspace_premium_outlined),
      _StatCard('Завершаемость', '${o.completionRate.toStringAsFixed(0)}%',
          Icons.trending_up),
    ];
    return Wrap(spacing: 16, runSpacing: 16, children: cards);
  }

  Widget _coursesHeader(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        Text('Курсы и статистика',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: t.text)),
        const Spacer(),
        FilledButton.icon(
          onPressed: () => context.go('/admin/courses/new'),
          icon: const Icon(Icons.add),
          label: const Text('Новый курс'),
        ),
      ],
    );
  }

  Widget _coursesTable(BuildContext context, DashboardController ctrl) {
    final t = context.tokens;
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Курс')),
            DataColumn(label: Text('Направление')),
            DataColumn(label: Text('Статус')),
            DataColumn(label: Text('Записан'), numeric: true),
            DataColumn(label: Text('Завершили'), numeric: true),
            DataColumn(label: Text('Ср. балл'), numeric: true),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (final c in ctrl.courses)
              DataRow(cells: [
                DataCell(Text(c.title)),
                DataCell(Text(c.category)),
                DataCell(c.isPublished
                    ? Text('Опубликован', style: TextStyle(color: t.accent))
                    : Text('Черновик', style: TextStyle(color: t.muted))),
                DataCell(Text('${ctrl.statFor(c.id)?.enrolled ?? 0}')),
                DataCell(Text('${ctrl.statFor(c.id)?.completed ?? 0}')),
                DataCell(Text(ctrl.statFor(c.id)?.avgScore == null
                    ? '—'
                    : '${ctrl.statFor(c.id)!.avgScore!.toStringAsFixed(0)}%')),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => context.go('/admin/courses/${c.id}'),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 20, color: t.danger),
                      onPressed: () => _confirmDelete(context, c.id),
                    ),
                  ],
                )),
              ]),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: 210,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.accentSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: t.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: t.text)),
                Text(label, style: TextStyle(color: t.muted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}