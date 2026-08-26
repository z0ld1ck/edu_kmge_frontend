import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<ProfileController>()..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  late final _name = TextEditingController();
  late final _dept = TextEditingController();
  late final _position = TextEditingController();
  bool _savingProfile = false;
  bool _seeded = false;

  @override
  void dispose() {
    _name.dispose();
    _dept.dispose();
    _position.dispose();
    super.dispose();
  }

  void _seed() {
    final user = context.read<AuthController>().user;
    if (user != null && !_seeded) {
      _name.text = user.fullName;
      _dept.text = user.department ?? '';
      _position.text = user.position ?? '';
      _seeded = true;
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _savingProfile = true);
    try {
      await context.read<AuthController>().refreshProfile(
        fullName: _name.text.trim(),
        department: _dept.text.trim(),
        position: _position.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Профиль сохранён')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    await showDialog(
      context: context,
      builder: (_) => const _PasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    _seed();
    final ctrl = context.watch<ProfileController>();
    final user = context.watch<AuthController>().user;
    return AppShell(
      title: 'Профиль',
      current: '/profile',
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _headerCard(context, ctrl, user.fullName, user.email,
                    user.role.label),
                const SizedBox(height: 16),
                _statsRow(context, ctrl),
                const SizedBox(height: 16),
                _achievements(context, ctrl),
                const SizedBox(height: 16),
                _profileForm(context),
                const SizedBox(height: 16),
                _appearance(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- Шапка: аватар, ранг, очки, лестница ----
  Widget _headerCard(BuildContext context, ProfileController ctrl, String name,
      String email, String roleLabel) {
    final t = context.tokens;
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0]).join();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: t.accent,
                  child: Text(initials.toUpperCase(),
                      style: TextStyle(
                          color: t.surface,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _rankChip(context, ctrl.rank),
                      const SizedBox(height: 6),
                      Text(name,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: t.text)),
                      Text('$email · $roleLabel',
                          style: TextStyle(color: t.muted, fontSize: 13)),
                    ],
                  ),
                ),
                _Ring(
                  value: ctrl.progressToNext,
                  size: 68,
                  center: '${ctrl.rank.level}',
                  caption: 'ур.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('${ctrl.points} очков безопасности',
                    style: TextStyle(fontWeight: FontWeight.w600, color: t.text)),
                const Spacer(),
                Text(
                    ctrl.nextRank == null
                        ? 'Максимальный ранг'
                        : 'до «${ctrl.nextRank!.label}» — ${ctrl.pointsToNext}',
                    style: TextStyle(color: t.muted, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ctrl.progressToNext,
                minHeight: 9,
                backgroundColor: t.ringTrack,
                valueColor: AlwaysStoppedAnimation(t.success),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (var i = 0; i < Rank.all.length; i++) ...[
                  _ladderChip(context, Rank.all[i], ctrl.rank),
                  if (i < Rank.all.length - 1)
                    Icon(Icons.chevron_right, size: 16, color: t.faint),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rankChip(BuildContext context, Rank rank) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: t.accentSoft, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.shield_outlined, size: 14, color: t.accentInk),
        const SizedBox(width: 5),
        Text('Уровень ${rank.level} · ${rank.label}',
            style: TextStyle(
                color: t.accentInk, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _ladderChip(BuildContext context, Rank rank, Rank current) {
    final t = context.tokens;
    final passed = rank.level < current.level;
    final isCurrent = rank == current;
    final bg = isCurrent
        ? t.accent
        : passed
        ? t.accentSoft
        : t.surface2;
    final fg = isCurrent
        ? t.surface
        : passed
        ? t.accentInk
        : t.faint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(rank.label,
          style: TextStyle(
              fontSize: 11.5, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  // ---- Статистика ----
  Widget _statsRow(BuildContext context, ProfileController ctrl) {
    return Row(
      children: [
        _stat(context, 'Пройдено курсов', '${ctrl.completedCourses}',
            Icons.school_outlined),
        const SizedBox(width: 12),
        _stat(context, 'Сдано тестов', '${ctrl.passedAttempts}',
            Icons.task_alt_outlined),
        const SizedBox(width: 12),
        _stat(context, 'Сертификатов', '${ctrl.certificates}',
            Icons.workspace_premium_outlined),
      ],
    );
  }

  Widget _stat(
      BuildContext context, String label, String value, IconData icon) {
    final t = context.tokens;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: t.accent, size: 20),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: t.text)),
            Text(label, style: TextStyle(color: t.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ---- Достижения (считаются из статистики) ----
  Widget _achievements(BuildContext context, ProfileController ctrl) {
    final t = context.tokens;
    final user = context.read<AuthController>().user;
    final badges = <_Badge>[
      _Badge('Первый курс', Icons.verified_outlined,
          ctrl.completedCourses >= 1),
      _Badge('Без ошибок', Icons.gps_fixed, ctrl.perfectScore),
      _Badge('3 курса', Icons.local_fire_department_outlined,
          ctrl.completedCourses >= 3),
      _Badge('Сертифицирован', Icons.workspace_premium_outlined,
          ctrl.certificates >= 1),
      _Badge('Марафонец', Icons.emoji_events_outlined,
          ctrl.completedCourses >= 10),
      _Badge('Наставник', Icons.school_outlined, user?.isStaff ?? false),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Достижения',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: t.text)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 18,
              runSpacing: 16,
              children: [for (final b in badges) _badgeTile(context, b)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeTile(BuildContext context, _Badge b) {
    final t = context.tokens;
    return SizedBox(
      width: 84,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: b.earned ? t.accentSoft : t.surface2,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(b.earned ? b.icon : Icons.lock_outline,
                color: b.earned ? t.accent : t.faint, size: 25),
          ),
          const SizedBox(height: 8),
          Text(b.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: b.earned ? t.text : t.faint)),
        ],
      ),
    );
  }

  // ---- Редактирование профиля ----
  Widget _profileForm(BuildContext context) {
    final t = context.tokens;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Личные данные',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: t.text)),
            const SizedBox(height: 16),
            TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'ФИО')),
            const SizedBox(height: 12),
            TextField(
                controller: _dept,
                decoration:
                const InputDecoration(labelText: 'Подразделение')),
            const SizedBox(height: 12),
            TextField(
                controller: _position,
                decoration: const InputDecoration(labelText: 'Должность')),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _savingProfile ? null : _saveProfile,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Сохранить'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _changePassword,
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: const Text('Сменить пароль'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---- Тема ----
  Widget _appearance(BuildContext context) {
    final t = context.tokens;
    final theme = context.watch<ThemeController>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Внешний вид',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: t.text)),
            const SizedBox(height: 4),
            Text('Тема оформления интерфейса',
                style: TextStyle(color: t.muted, fontSize: 13)),
            const SizedBox(height: 14),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('Система'),
                    icon: Icon(Icons.brightness_auto)),
                ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Светлая'),
                    icon: Icon(Icons.light_mode_outlined)),
                ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Тёмная'),
                    icon: Icon(Icons.dark_mode_outlined)),
              ],
              selected: {theme.mode},
              onSelectionChanged: (s) => theme.set(s.first),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge {
  final String label;
  final IconData icon;
  final bool earned;
  const _Badge(this.label, this.icon, this.earned);
}

/// Кольцо прогресса с текстом в центре.
class _Ring extends StatelessWidget {
  final double value;
  final double size;
  final String center;
  final String? caption;
  const _Ring(
      {required this.value,
        required this.size,
        required this.center,
        this.caption});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 6,
              backgroundColor: t.ringTrack,
              valueColor: AlwaysStoppedAnimation(t.success),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: t.text)),
              if (caption != null)
                Text(caption!,
                    style: TextStyle(fontSize: 10, color: t.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    if (_new.text.length < 6) {
      setState(() => _error = 'Новый пароль — не короче 6 символов');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context
          .read<AuthController>()
          .changePassword(_old.text, _new.text);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Пароль изменён')));
      }
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
      title: const Text('Смена пароля'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _old,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Текущий пароль')),
            const SizedBox(height: 12),
            TextField(
                controller: _new,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Новый пароль')),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: t.danger)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена')),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: t.surface))
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}