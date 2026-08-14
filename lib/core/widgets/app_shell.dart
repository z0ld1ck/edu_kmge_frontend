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
                if (v == 'logout') context.read<AuthController>().logout();
              },
              itemBuilder: (c) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text((user?.role ?? UserRole.student).label,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'logout', child: Text('Выйти')),
              ],
            ),
          ),
        ],
      ),
      drawer: wide ? null : Drawer(child: SafeArea(child: navList())),
      body: Row(
        children: [
          if (wide)
            Container(
              width: 260,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: const [
                        Icon(Icons.eco, color: AppColors.brand),
                        SizedBox(width: 8),
                        Text('KMGE Edu',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brand)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(child: navList()),
                ],
              ),
            ),
          Expanded(
            child: Container(color: AppColors.background, child: body),
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Material(
        color: selected ? AppColors.brand.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          leading:
          Icon(item.icon, color: selected ? AppColors.brand : Colors.grey.shade700),
          title: Text(item.label,
              style: TextStyle(
                  color: selected ? AppColors.brand : Colors.grey.shade800,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onTap: onTap,
        ),
      ),
    );
  }
}
