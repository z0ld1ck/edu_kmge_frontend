import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../learning/domain/entities/enrollment.dart';
import '../../domain/entities/assignment.dart';
import '../controllers/assignments_controller.dart';

class AdminAssignmentsPage extends StatelessWidget {
  const AdminAssignmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<AssignmentsController>()..load(),
      child: const _AssignmentsView(),
    );
  }
}

class _AssignmentsView extends StatelessWidget {
  const _AssignmentsView();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AssignmentsController>();
    return AppShell(
      title: 'Назначения',
      current: '/admin/assignments',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilledButton.icon(
            onPressed: () => _openAssignDialog(context, ctrl),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Назначить курс'),
          ),
        ),
      ],
      body: Column(
        children: [
          _filters(context, ctrl),
          Expanded(
            child: ctrl.loading
                ? const Center(child: CircularProgressIndicator())
                : ctrl.error != null
                ? Center(child: Text('Ошибка: ${ctrl.error}'))
                : ctrl.items.isEmpty
                ? _empty(context)
                : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              children: [
                for (final a in ctrl.items) _row(context, ctrl, a),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context, AssignmentsController ctrl) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 260,
            child: DropdownButtonFormField<int?>(
              initialValue: ctrl.filterCourseId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Курс',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Все курсы')),
                for (final c in ctrl.courses)
                  DropdownMenuItem(
                      value: c.id,
                      child: Text(c.title, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => ctrl.setCourseFilter(v),
            ),
          ),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String?>(
              initialValue: ctrl.filterStatus,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Статус',
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Все')),
                DropdownMenuItem(value: 'pending', child: Text('В процессе')),
                DropdownMenuItem(value: 'overdue', child: Text('Просрочено')),
                DropdownMenuItem(value: 'completed', child: Text('Завершено')),
              ],
              onChanged: (v) => ctrl.setStatusFilter(v),
            ),
          ),
          Text('Всего: ${ctrl.items.length}',
              style: TextStyle(color: t.muted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: t.faint),
          const SizedBox(height: 12),
          const Text('Пока нет назначений'),
          const SizedBox(height: 4),
          Text('Нажмите «Назначить курс», чтобы выдать курс сотрудникам',
              style: TextStyle(color: t.muted)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, AssignmentsController ctrl, Assignment a) {
    final t = context.tokens;
    final done = a.status.isCompleted;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: t.accentSoft,
              child: Text(
                _initials(a.userName),
                style: TextStyle(
                    color: t.accentInk, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(a.userName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: t.text)),
                      ),
                      if (a.department != null) ...[
                        const SizedBox(width: 8),
                        Text(a.department!,
                            style:
                            TextStyle(color: t.faint, fontSize: 12)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(a.courseTitle,
                      style: TextStyle(color: t.muted, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _statusChip(context, a),
                      if (a.isMandatory) ...[
                        const SizedBox(width: 6),
                        _chip(context, 'Обязательный', t.accentInk,
                            t.accentSoft),
                      ],
                      if (a.dueDate != null && !done && !a.isOverdue) ...[
                        const SizedBox(width: 6),
                        _chip(context, 'до ${_fmtDate(a.dueDate!)}', t.muted,
                            t.surface2),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${a.progress.toStringAsFixed(0)}%',
                      style: TextStyle(
                          color: t.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: a.progress / 100,
                      minHeight: 6,
                      backgroundColor: t.ringTrack,
                      valueColor: AlwaysStoppedAnimation(t.accent),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Снять назначение',
              icon: Icon(Icons.close, size: 18, color: t.faint),
              onPressed: () => _confirmRemove(context, ctrl, a),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context, Assignment a) {
    final t = context.tokens;
    if (a.status.isCompleted) {
      return _chip(context, 'Завершён', t.accentInk, t.accentSoft);
    }
    if (a.isOverdue) {
      final over = -(a.daysLeft ?? 0);
      return _chip(context, 'Просрочено на $over ${_plural(over)}', t.danger,
          t.dangerSoft);
    }
    final left = a.daysLeft;
    if (left != null) {
      final soon = left <= 3;
      return _chip(
        context,
        left == 0 ? 'Сегодня дедлайн' : 'Осталось $left ${_plural(left)}',
        soon ? t.danger : t.info,
        soon ? t.dangerSoft : t.infoSoft,
      );
    }
    return _chip(context, 'В процессе', t.info, t.infoSoft);
  }

  Widget _chip(BuildContext context, String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              color: fg, fontSize: 11.5, fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _confirmRemove(
      BuildContext context, AssignmentsController ctrl, Assignment a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Снять назначение?'),
        content: Text(
            'Курс «${a.courseTitle}» для ${a.userName}. Прогресс сотрудника сохранится, но дедлайн и обязательность будут сняты.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Отмена')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Снять')),
        ],
      ),
    );
    if (ok == true) {
      final done = await ctrl.remove(a.enrollmentId);
      if (context.mounted && done) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Назначение снято')));
      }
    }
  }

  Future<void> _openAssignDialog(
      BuildContext context, AssignmentsController ctrl) async {
    final n = await showDialog<int>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: ctrl,
        child: const _AssignDialog(),
      ),
    );
    if (n != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Назначено сотрудникам: $n')),
      );
    }
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
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

// ------------------- Диалог назначения -------------------

class _AssignDialog extends StatefulWidget {
  const _AssignDialog();

  @override
  State<_AssignDialog> createState() => _AssignDialogState();
}

enum _Target { users, department }

class _AssignDialogState extends State<_AssignDialog> {
  int? _courseId;
  _Target _target = _Target.users;
  final Set<int> _userIds = {};
  String? _department;
  DateTime? _dueDate;
  bool _mandatory = true;
  bool _saving = false;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ctrl = context.read<AssignmentsController>();
    final courses = ctrl.courses;
    final users = _filteredUsers(ctrl.allUsers);

    return AlertDialog(
      title: const Text('Назначить курс'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _courseId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Курс *'),
                items: [
                  for (final Course c in courses)
                    DropdownMenuItem(
                        value: c.id,
                        child:
                        Text(c.title, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => setState(() => _courseId = v),
              ),
              const SizedBox(height: 16),
              Text('Кому назначить',
                  style: TextStyle(
                      color: t.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              SegmentedButton<_Target>(
                segments: const [
                  ButtonSegment(
                      value: _Target.users,
                      label: Text('Сотрудники'),
                      icon: Icon(Icons.person_outline, size: 16)),
                  ButtonSegment(
                      value: _Target.department,
                      label: Text('Подразделение'),
                      icon: Icon(Icons.apartment_outlined, size: 16)),
                ],
                selected: {_target},
                onSelectionChanged: (s) =>
                    setState(() => _target = s.first),
              ),
              const SizedBox(height: 12),
              if (_target == _Target.users)
                _usersPicker(context, users)
              else
                _departmentPicker(context, ctrl.departments),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.event, size: 18),
                      label: Text(_dueDate == null
                          ? 'Срок сдачи (необяз.)'
                          : 'До ${_AssignmentsViewFmt.fmt(_dueDate!)}'),
                    ),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      tooltip: 'Убрать срок',
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _dueDate = null),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _mandatory,
                onChanged: (v) => setState(() => _mandatory = v),
                title: const Text('Обязательный курс'),
                subtitle: Text('Отметить назначение как обязательное',
                    style: TextStyle(color: t.faint, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed:
            _saving ? null : () => Navigator.pop(context),
            child: const Text('Отмена')),
        FilledButton(
          onPressed: _saving || !_canSubmit ? null : () => _submit(ctrl),
          child: _saving
              ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Назначить'),
        ),
      ],
    );
  }

  bool get _canSubmit {
    if (_courseId == null) return false;
    if (_target == _Target.users) return _userIds.isNotEmpty;
    return _department != null && _department!.isNotEmpty;
  }

  List<User> _filteredUsers(List<User> users) {
    final base = users.where((u) => u.role == UserRole.student).toList();
    if (_search.trim().isEmpty) return base;
    final q = _search.toLowerCase();
    return base
        .where((u) =>
    u.fullName.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q) ||
        (u.department ?? '').toLowerCase().contains(q))
        .toList();
  }

  Widget _usersPicker(BuildContext context, List<User> users) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Поиск сотрудника…',
            prefixIcon: Icon(Icons.search, size: 18),
            isDense: true,
          ),
          onChanged: (v) => setState(() => _search = v),
        ),
        const SizedBox(height: 8),
        Text('Выбрано: ${_userIds.length}',
            style: TextStyle(color: t.muted, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: t.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: users.isEmpty
              ? Center(
              child: Text('Нет сотрудников',
                  style: TextStyle(color: t.faint)))
              : ListView.builder(
            itemCount: users.length,
            itemBuilder: (c, i) {
              final u = users[i];
              final on = _userIds.contains(u.id);
              return CheckboxListTile(
                dense: true,
                value: on,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(u.fullName,
                    style: TextStyle(color: t.text, fontSize: 14)),
                subtitle: Text(
                  u.department == null || u.department!.isEmpty
                      ? u.email
                      : '${u.department} · ${u.email}',
                  style: TextStyle(color: t.faint, fontSize: 12),
                ),
                onChanged: (v) => setState(() {
                  if (v == true) {
                    _userIds.add(u.id);
                  } else {
                    _userIds.remove(u.id);
                  }
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _departmentPicker(BuildContext context, List<String> departments) {
    final t = context.tokens;
    if (departments.isEmpty) {
      return Text('У сотрудников не заданы подразделения',
          style: TextStyle(color: t.faint));
    }
    return DropdownButtonFormField<String>(
      initialValue: _department,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Подразделение *'),
      items: [
        for (final d in departments)
          DropdownMenuItem(value: d, child: Text(d)),
      ],
      onChanged: (v) => setState(() => _department = v),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit(AssignmentsController ctrl) async {
    setState(() => _saving = true);
    final n = await ctrl.assign(
      courseId: _courseId!,
      userIds: _target == _Target.users ? _userIds.toList() : const [],
      department: _target == _Target.department ? _department : null,
      dueDate: _dueDate,
      isMandatory: _mandatory,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (n != null) {
      Navigator.pop(context, n);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${ctrl.error ?? 'не удалось назначить'}')),
      );
    }
  }
}

class _AssignmentsViewFmt {
  static String fmt(DateTime d) {
    const m = [
      'янв', 'фев', 'мар', 'апр', 'мая', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}
