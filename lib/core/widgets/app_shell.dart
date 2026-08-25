import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../theme/app_theme.dart';

/// Каркас страницы с боковой навигацией (десктоп) / drawer (мобильный).
class AppShell extends StatelessWidget {
  final String title;
  final Widget body;
  final String current;
  final List<Widget> actions;

  const AppShell({
    super.key,
    required this.title,
    required this.body,
    required this.current,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final user = context.watch<AuthController>().user;
    final wide = MediaQuery.of(context).size.width >= 900;

    final items = <_NavItem>[
      const _NavItem('/catalog', 'Каталог курсов', Icons.school_outlined),
      const _NavItem('/my', 'Мои курсы', Icons.menu_book_outlined),
      const _NavItem(
          '/certificates', 'Сертификаты', Icons.workspace_premium_outlined),
      if (user?.isStaff ?? false)
        const _NavItem('/admin', 'Панель управления', Icons.dashboard_outlined),
      if (user?.isStaff ?? false)
        const _NavItem('/admin/users', 'Пользователи', Icons.people_outline),
      if (user?.isStaff ?? false)
        const _NavItem(
            '/admin/assignments', 'Назначения', Icons.assignment_outlined),
    ];

    Widget navList() => ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        for (final it in items)
          _NavTile(
            item: it,
            selected: current == it.route ||
                (it.route == '/admin' &&
                    current.startsWith('/admin/courses')),
            onTap: () {
              if (!wide) Navigator.of(context).pop();
              context.go(it.route);
            },
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ...actions,
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              tooltip: user?.fullName ?? '',
              icon: const Icon(Icons.account_circle_outlined),
              onSelected: (v) {
                if (v == 'profile') context.go('/profile');
                if (v == 'logout') context.read<AuthController>().logout();
              },
              itemBuilder: (c) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: t.text)),
                      Text((user?.role ?? UserRole.student).label,
                          style: TextStyle(fontSize: 12, color: t.muted)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                    value: 'profile', child: Text('Профиль')),
                const PopupMenuItem(value: 'logout', child: Text('Выйти')),
              ],
            ),
          ),
        ],
      ),
      drawer: wide
          ? null
          : Drawer(
        backgroundColor: t.surface,
        child: SafeArea(child: navList()),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide)
            Container(
              width: 260,
              decoration: BoxDecoration(
                color: t.surface,
                border: Border(right: BorderSide(color: t.border)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(Icons.eco, color: t.accent),
                        const SizedBox(width: 8),
                        Text('KMGE Edu',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: t.accent)),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: t.border),
                  Expanded(child: navList()),
                ],
              ),
            ),
          Expanded(child: Container(color: t.bg, child: body)),
        ],
      ),
    );
  }
}

class _NavItem {
  final String route;
  final String label;
  final IconData icon;
  const _NavItem(this.route, this.label, this.icon);
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _NavTile(
      {required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Material(
        color: selected ? t.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          leading: Icon(item.icon, color: selected ? t.accent : t.muted),
          title: Text(item.label,
              style: TextStyle(
                  color: selected ? t.accentInk : t.text,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500)),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onTap: onTap,
        ),
      ),
    );
  }
}