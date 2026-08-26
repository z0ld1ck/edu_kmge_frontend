import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import 'app_icons.dart';

const _navBg = Color(0xFF14121E);
const _navMuted = Color(0xFF8E8AA0);
const _navInk = Color(0xFFFFFFFF);

class AppShell extends StatelessWidget {
  final String title; // для совместимости; вверху не показывается
  final Widget body;
  final String current;
  final List<Widget> actions;
  final Widget? leading; // напр. кнопка «назад» слева вверху
  final Widget? search; // компактный поиск в верхней панели (справа)

  const AppShell({
    super.key,
    required this.title,
    required this.body,
    required this.current,
    this.actions = const [],
    this.leading,
    this.search,
  });

  List<_NavItem> _items(BuildContext context) {
    final user = context.watch<AuthController>().user;
    final staff = user?.isStaff ?? false;
    return [
      const _NavItem('/catalog', 'Каталог', 'home'),
      const _NavItem('/my', 'Мои курсы', 'book'),
      const _NavItem('/certificates', 'Сертификаты', 'award'),
      if (staff) const _NavItem('/admin', 'Панель', 'grid'),
      if (staff) const _NavItem('/admin/users', 'Пользователи', 'users'),
      if (staff)
        const _NavItem('/admin/assignments', 'Назначения', 'clipboard'),
    ];
  }

  bool _isSelected(_NavItem it) =>
      current == it.route ||
      (it.route == '/admin' && current.startsWith('/admin/courses'));

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final wide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      drawer: wide ? null : Drawer(child: _sidebar(context, inDrawer: true)),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide) _sidebar(context),
          Expanded(
            child: Container(
              color: t.bg,
              child: Column(
                children: [
                  _topBar(context, wide),
                  Expanded(child: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context, bool wide) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          if (!wide)
            Builder(
              builder: (c) => IconButton(
                icon: Icon(Icons.menu, color: t.text),
                onPressed: () => Scaffold.of(c).openDrawer(),
              ),
            ),
          if (leading != null) leading!,
          const Spacer(),
          ...actions,
          if (search != null && wide) ...[search!, const SizedBox(width: 12)],
          _iconBtn(context, 'bell', () {}),
          const SizedBox(width: 8),
          _profileButton(context),
        ],
      ),
    );
  }

  Widget _iconBtn(BuildContext context, String icon, VoidCallback onTap) {
    final t = context.tokens;
    return Material(
      color: t.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: t.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: AppIcon(icon, size: 20, color: t.muted),
        ),
      ),
    );
  }

  Widget _profileButton(BuildContext context) {
    final t = context.tokens;
    final user = context.watch<AuthController>().user;
    return PopupMenuButton<String>(
      tooltip: user?.fullName ?? '',
      offset: const Offset(0, 48),
      onSelected: (v) {
        if (v == 'profile') context.go('/profile');
        if (v == 'logout') context.read<AuthController>().logout();
      },
      itemBuilder: (c) => const [
        PopupMenuItem(value: 'profile', child: Text('Профиль')),
        PopupMenuItem(value: 'logout', child: Text('Выйти')),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: t.text,
              child: AppIcon('user', size: 18, color: t.surface),
            ),
            const SizedBox(width: 8),
            Text(
              _shortName(user?.fullName),
              style: TextStyle(
                color: t.text,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Icon(Icons.expand_more, size: 18, color: t.muted),
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }

  static String _shortName(String? full) {
    if (full == null || full.trim().isEmpty) return 'Профиль';
    final parts = full.trim().split(RegExp(r'\s+'));
    return parts.length >= 2 ? '${parts[0]} ${parts[1][0]}.' : parts[0];
  }

  Widget _sidebar(BuildContext context, {bool inDrawer = false}) {
    final items = _items(context);
    return Container(
      width: 264,
      color: _navBg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: context.tokens.accent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.eco, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'KMGE Edu',
                    style: TextStyle(
                      color: _navInk,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final it in items)
                    _NavTile(
                      item: it,
                      selected: _isSelected(it),
                      onTap: () {
                        if (inDrawer) Navigator.of(context).pop();
                        context.go(it.route);
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
              child: _NavTile(
                item: const _NavItem('__logout__', 'Выйти', 'logout'),
                selected: false,
                onTap: () {
                  if (inDrawer) Navigator.of(context).pop();
                  context.read<AuthController>().logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String route;
  final String label;
  final String icon;

  const _NavItem(this.route, this.label, this.icon);
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ink = selected ? _navInk : _navMuted;
    return SizedBox(
      height: 52,
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      AppIcon(item.icon, size: 21, color: ink),
                      const SizedBox(width: 14),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: ink,
                          fontSize: 14.5,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (selected)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 5,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(6),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
