// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/import_result.dart';
import '../controllers/users_controller.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<UsersController>()..load(),
      child: const _UsersView(),
    );
  }
}

class _UsersView extends StatelessWidget {
  const _UsersView();

  Future<void> _openForm(BuildContext context, {User? user}) async {
    final ctrl = context.read<UsersController>();
    await showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: ctrl,
        child: _UserFormDialog(user: user),
      ),
    );
  }

  Future<void> _delete(BuildContext context, User u) async {
    final ctrl = context.read<UsersController>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Удалить ${u.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ctrl.delete(u.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  void _downloadTemplate() {
    const csv =
        'email,full_name,department,position,role,password\n'
        'ivanov@kmge.kz,Иванов Иван Иванович,Цех №1,Оператор,student,\n'
        'petrov@kmge.kz,Петров Пётр,Цех №2,Мастер,teacher,secret123\n';
    final bytes = const Utf8Encoder().convert('﻿$csv'); // BOM — для Excel
    final url = html.Url.createObjectUrlFromBlob(
      html.Blob([bytes], 'text/csv'),
    );
    html.AnchorElement(href: url)
      ..setAttribute('download', 'users_template.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _import(BuildContext context) async {
    final input = html.FileUploadInputElement()
      ..accept = '.csv,.xlsx'
      ..style.display = 'none';
    html.document.body?.append(input);
    input.click();
    await input.onChange.first;
    final files = input.files;
    input.remove();
    if (files == null || files.isEmpty) return;
    final f = files.first;
    final reader = html.FileReader()..readAsArrayBuffer(f);
    await reader.onLoadEnd.first;
    final result = reader.result;
    final Uint8List bytes = result is ByteBuffer
        ? result.asUint8List()
        : result as Uint8List;

    if (!context.mounted) return;
    final ctrl = context.read<UsersController>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final res = await ctrl.importUsers(bytes: bytes, filename: f.name);
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) _showResult(context, res);
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка импорта: $e')));
      }
    }
  }

  void _showResult(BuildContext context, UserImportResult res) {
    final t = context.tokens;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Результат импорта'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _stat(context, 'Создано', '${res.created}', t.accent),
                    const SizedBox(width: 10),
                    _stat(context, 'Пропущено', '${res.skipped}', t.muted),
                    const SizedBox(width: 10),
                    _stat(
                      context,
                      'Ошибок',
                      '${res.issues.length}',
                      res.issues.isEmpty ? t.muted : t.danger,
                    ),
                  ],
                ),
                if (res.accounts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Созданные аккаунты и пароли',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: t.text,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          final text = res.accounts
                              .map(
                                (a) =>
                                    '${a.email}\t${a.fullName}\t${a.password}',
                              )
                              .join('\n');
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(c).showSnackBar(
                            const SnackBar(
                              content: Text('Скопировано в буфер обмена'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Копировать'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: t.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final a in res.accounts)
                          ListTile(
                            dense: true,
                            title: Text(
                              a.fullName,
                              style: TextStyle(color: t.text, fontSize: 13.5),
                            ),
                            subtitle: Text(
                              a.email,
                              style: TextStyle(color: t.faint, fontSize: 12),
                            ),
                            trailing: SelectableText(
                              a.password,
                              style: TextStyle(
                                color: t.accentInk,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    'Сохраните пароли — потом их увидеть нельзя.',
                    style: TextStyle(color: t.faint, fontSize: 12),
                  ),
                ],
                if (res.issues.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Проблемы',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: t.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final i in res.issues)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'Строка ${i.row}: ${i.email.isEmpty ? '—' : i.email} — ${i.reason}',
                        style: TextStyle(color: t.danger, fontSize: 12.5),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Готово'),
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value, Color color) {
    final t = context.tokens;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: t.surface2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: TextStyle(color: t.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<UsersController>();
    return AppShell(
      title: 'Пользователи',
      current: '/admin/users',
      actions: [
        IconButton(
          tooltip: 'Скачать шаблон CSV',
          icon: const Icon(Icons.description_outlined),
          onPressed: _downloadTemplate,
        ),
        IconButton(
          tooltip: 'Импорт из файла (CSV/Excel)',
          icon: const Icon(Icons.upload_file),
          onPressed: () => _import(context),
        ),
        IconButton(
          tooltip: 'Добавить пользователя',
          icon: const Icon(Icons.person_add_alt),
          onPressed: () => _openForm(context),
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Поиск по имени или email…',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: ctrl.setQuery,
            ),
          ),
          Expanded(
            child: ctrl.loading
                ? const Center(child: CircularProgressIndicator())
                : ctrl.error != null
                ? Center(child: Text('Ошибка: ${ctrl.error}'))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [for (final u in ctrl.users) _tile(context, u)],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, User u) {
    final t = context.tokens;
    final rc = _roleColor(t, u.role);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rc.withOpacity(0.15),
          child: Icon(Icons.person, color: rc),
        ),
        title: Text(
          u.fullName,
          style: TextStyle(fontWeight: FontWeight.w600, color: t.text),
        ),
        subtitle: Text(
          '${u.email}${u.department != null ? " • ${u.department}" : ""}',
          style: TextStyle(color: t.muted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                u.role.label,
                style: TextStyle(fontSize: 12, color: rc),
              ),
              backgroundColor: rc.withOpacity(0.12),
              side: BorderSide.none,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _openForm(context, user: u),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: t.danger),
              onPressed: () => _delete(context, u),
            ),
          ],
        ),
      ),
    );
  }

  static Color _roleColor(AppTokens t, UserRole role) => switch (role) {
    UserRole.admin => t.info,
    UserRole.teacher => t.amber,
    _ => t.accent,
  };
}

class _UserFormDialog extends StatefulWidget {
  final User? user;

  const _UserFormDialog({this.user});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  late final _name = TextEditingController(text: widget.user?.fullName ?? '');
  late final _email = TextEditingController(text: widget.user?.email ?? '');
  late final _dept = TextEditingController(text: widget.user?.department ?? '');
  late final _position = TextEditingController(
    text: widget.user?.position ?? '',
  );
  final _password = TextEditingController();
  late UserRole _role = widget.user?.role ?? UserRole.student;
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.user != null;

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final ctrl = context.read<UsersController>();
    try {
      if (_isEdit) {
        await ctrl.update(
          widget.user!.id,
          fullName: _name.text.trim(),
          department: _dept.text.trim(),
          position: _position.text.trim(),
          role: _role,
          password: _password.text,
        );
      } else {
        await ctrl.create(
          email: _email.text.trim(),
          fullName: _name.text.trim(),
          department: _dept.text.trim(),
          position: _position.text.trim(),
          role: _role,
          password: _password.text,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AlertDialog(
      title: Text(
        _isEdit ? 'Редактировать пользователя' : 'Новый пользователь',
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'ФИО'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                enabled: !_isEdit,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dept,
                decoration: const InputDecoration(labelText: 'Подразделение'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _position,
                decoration: const InputDecoration(labelText: 'Должность'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Роль'),
                items: const [
                  DropdownMenuItem(
                    value: UserRole.student,
                    child: Text('Студент'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.teacher,
                    child: Text('Преподаватель'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.admin,
                    child: Text('Администратор'),
                  ),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _isEdit
                      ? 'Новый пароль (необязательно)'
                      : 'Пароль',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: t.danger)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}
