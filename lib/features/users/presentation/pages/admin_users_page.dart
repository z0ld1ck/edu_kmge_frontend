import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../auth/domain/entities/user.dart';
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
              child: const Text('Отмена')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Удалить')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ctrl.delete(u.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<UsersController>();
    return AppShell(
      title: 'Пользователи',
      current: '/admin/users',
      actions: [
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
                  prefixIcon: Icon(Icons.search)),
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
              children: [
                for (final u in ctrl.users) _tile(context, u)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, User u) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _roleColor(u.role).withOpacity(0.15),
          child: Icon(Icons.person, color: _roleColor(u.role)),
        ),
        title:
        Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${u.email}${u.department != null ? " • ${u.department}" : ""}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(u.role.label, style: const TextStyle(fontSize: 12)),
              backgroundColor: _roleColor(u.role).withOpacity(0.12),
              side: BorderSide.none,
            ),
            IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _openForm(context, user: u)),
            IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.redAccent),
                onPressed: () => _delete(context, u)),
          ],
        ),
      ),
    );
  }

  static Color _roleColor(UserRole role) => switch (role) {
    UserRole.admin => Colors.deepPurple,
    UserRole.teacher => Colors.orange,
    _ => AppColors.brand,
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
  late final _position =
  TextEditingController(text: widget.user?.position ?? '');
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
    return AlertDialog(
      title: Text(_isEdit ? 'Редактировать пользователя' : 'Новый пользователь'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'ФИО')),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                enabled: !_isEdit,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: _dept,
                  decoration:
                  const InputDecoration(labelText: 'Подразделение')),
              const SizedBox(height: 12),
              TextField(
                  controller: _position,
                  decoration: const InputDecoration(labelText: 'Должность')),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Роль'),
                items: const [
                  DropdownMenuItem(
                      value: UserRole.student, child: Text('Студент')),
                  DropdownMenuItem(
                      value: UserRole.teacher, child: Text('Преподаватель')),
                  DropdownMenuItem(
                      value: UserRole.admin, child: Text('Администратор')),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                    labelText:
                    _isEdit ? 'Новый пароль (необязательно)' : 'Пароль'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена')),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}
