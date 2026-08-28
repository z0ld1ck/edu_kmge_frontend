import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../di/injection.dart';
import '../network/api_client.dart';
import '../theme/app_theme.dart';
import 'app_icons.dart';

// Тёмный навбар (референс): единый цвет вне зависимости от темы.
const _navBg = Color(0xFF14121E);
const _navMuted = Color(0xFF8E8AA0);
const _navInk = Color(0xFFFFFFFF);

/// Каркас страницы: тёмная боковая навигация + область контента.
class AppShell extends StatelessWidget {
  final String title; // оставлен для совместимости; вверху не показывается
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

  // ---------- Верхняя панель контента (без названия страницы) ----------
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
          const _NotificationsBell(),
          const SizedBox(width: 8),
          const _ProfileButton(),
        ],
      ),
    );
  }

  static String _shortName(String? full) {
    if (full == null || full.trim().isEmpty) return 'Профиль';
    final parts = full.trim().split(RegExp(r'\s+'));
    return parts.length >= 2 ? '${parts[0]} ${parts[1][0]}.' : parts[0];
  }

  // ---------- Тёмный сайдбар ----------
  Widget _sidebar(BuildContext context, {bool inDrawer = false}) {
    final items = _items(context);
    return Container(
      width: 264,
      color: _navBg,
      child: SafeArea(
        child: Column(
          children: [
            // Логотип
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
            // Логаут — отдельно внизу
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
          // Белый индикатор активной страницы на правой границе навбара.
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

// ---------- Кнопка профиля с меню той же ширины ----------
class _ProfileButton extends StatefulWidget {
  const _ProfileButton();

  @override
  State<_ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<_ProfileButton> {
  final _key = GlobalKey();
  double? _width;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final user = context.watch<AuthController>().user;
    // После кадра запоминаем фактическую ширину кнопки для меню.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final w = _key.currentContext?.size?.width;
      if (w != null && w != _width) setState(() => _width = w);
    });
    return PopupMenuButton<String>(
      tooltip: user?.fullName ?? '',
      offset: const Offset(0, 48),
      constraints: _width == null
          ? null
          : BoxConstraints(minWidth: _width!, maxWidth: _width!),
      onSelected: (v) {
        if (v == 'profile') context.go('/profile');
        if (v == 'logout') context.read<AuthController>().logout();
      },
      itemBuilder: (c) => const [
        PopupMenuItem(value: 'profile', child: Text('Профиль')),
        PopupMenuItem(value: 'logout', child: Text('Выйти')),
      ],
      child: Container(
        key: _key,
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
              AppShell._shortName(user?.fullName),
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
}

// ---------- Уведомления о дедлайнах ----------
class _Notif {
  final int courseId;
  final String courseTitle;
  final DateTime dueDate;
  final int daysLeft; // отрицательное — просрочено
  final bool isOverdue;
  final bool isMandatory;

  _Notif({
    required this.courseId,
    required this.courseTitle,
    required this.dueDate,
    required this.daysLeft,
    required this.isOverdue,
    required this.isMandatory,
  });

  factory _Notif.fromJson(Map<String, dynamic> j) => _Notif(
    courseId: j['course_id'] as int,
    courseTitle: (j['course_title'] ?? '') as String,
    dueDate: DateTime.parse(j['due_date'] as String),
    daysLeft: (j['days_left'] ?? 0) as int,
    isOverdue: j['is_overdue'] == true,
    isMandatory: j['is_mandatory'] == true,
  );

  bool get urgent => isOverdue || daysLeft <= 3;
}

class _NotificationsBell extends StatefulWidget {
  const _NotificationsBell();

  @override
  State<_NotificationsBell> createState() => _NotificationsBellState();
}

class _NotificationsBellState extends State<_NotificationsBell> {
  List<_Notif> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await sl<ApiClient>().get('/api/my/notifications');
      if (!mounted) return;
      setState(
        () => _items = (data as List)
            .map((e) => _Notif.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      // тихо игнорируем — колокольчик просто без бейджа
    }
  }

  int get _badge => _items.where((n) => n.urgent).length;

  void _open() {
    final t = context.tokens;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.15),
      builder: (_) => Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 66, right: 76),
          child: Material(
            color: t.surface,
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            shadowColor: Colors.black.withOpacity(0.15),
            child: Container(
              width: 340,
              constraints: const BoxConstraints(maxHeight: 420),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: t.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Text(
                      'Дедлайны',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: t.text,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: t.border),
                  if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Нет активных дедлайнов',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: t.muted, fontSize: 13),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _items.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: t.border),
                        itemBuilder: (_, i) => _tile(context, _items[i]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, _Notif n) {
    final t = context.tokens;
    final Color c = n.urgent ? t.danger : t.muted;
    final String status;
    if (n.isOverdue) {
      status = 'Просрочено · ${_fmt(n.dueDate)}';
    } else if (n.daysLeft == 0) {
      status = 'Сегодня дедлайн · ${_fmt(n.dueDate)}';
    } else {
      status =
          'Осталось ${n.daysLeft} ${_plural(n.daysLeft)} · до ${_fmt(n.dueDate)}';
    }
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        context.push('/courses/${n.courseId}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              n.isOverdue ? Icons.error_outline : Icons.schedule,
              size: 18,
              color: c,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.courseTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: t.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    status,
                    style: TextStyle(
                      color: c,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (n.isMandatory)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Icon(Icons.push_pin, size: 14, color: t.amber),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: t.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _open,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AppIcon('bell', size: 20, color: t.muted),
              if (_badge > 0)
                Positioned(
                  right: -4,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: const BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                    ),
                    decoration: BoxDecoration(
                      color: t.danger,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: t.surface, width: 1.5),
                    ),
                    child: Text(
                      '$_badge',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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

  static String _fmt(DateTime d) {
    const m = [
      'янв',
      'фев',
      'мар',
      'апр',
      'мая',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}
