import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../ai/domain/repositories/ai_repository.dart';
import '../../../ai/presentation/widgets/ai_chat_dialog.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/lesson.dart';
import '../controllers/course_detail_controller.dart';
import 'lesson_page.dart';
import 'quiz_page.dart';

// Цвета «пустынной» сцены — единые для свет/тьмы (это оформленная карта).
const _sand = Color(0xFFF1E6CB);
const _sandDark = Color(0xFFF1E6CB);
const _trail = Color(0xFFC7A76B);
const _sandInk = Color(0xFF6B5636);

const double _rigSize = 140;
const double _nodeSize = 128;
const double _spacing = 168;
const double _topPad = 56;

/// Страница курса в виде «маршрута» (как в Duolingo), тематика — нефтегаз.
class CoursePathPage extends StatelessWidget {
  final int courseId;

  const CoursePathPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<CourseDetailController>()..load(courseId),
      child: _PathView(courseId: courseId),
    );
  }
}

class _PathView extends StatelessWidget {
  final int courseId;

  const _PathView({required this.courseId});

  void _openAi(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (_) => AiChatDialog(
        courseId: courseId,
        courseTitle: title,
        repository: sl<AiRepository>(),
      ),
    );
  }

  Future<void> _openLesson(
    BuildContext context,
    CourseDetailController ctrl,
    Lesson lesson,
    int i,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: ctrl,
          child: LessonPage(lesson: lesson, index: i),
        ),
      ),
    );
  }

  Future<void> _openQuiz(
    BuildContext context,
    CourseDetailController ctrl,
    String title,
  ) async {
    final passed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => QuizPage(courseId: courseId, courseTitle: title),
      ),
    );
    if (passed == true) ctrl.load(courseId);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CourseDetailController>();
    final isStaff = context.read<AuthController>().user?.isStaff ?? false;
    final course = ctrl.course;

    return AppShell(
      title: course?.title ?? 'Курс',
      current: '/catalog',
      actions: [
        if (ctrl.aiEnabled && course != null)
          IconButton(
            tooltip: 'AI-ассистент',
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: () => _openAi(context, course.title),
          ),
        if (isStaff && course != null)
          IconButton(
            tooltip: 'Редактировать',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/admin/courses/$courseId'),
          ),
      ],
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.error != null
          ? Center(child: Text('Ошибка: ${ctrl.error}'))
          : !ctrl.enrolled
          ? _startScreen(context, ctrl)
          : _scene(context, ctrl),
    );
  }

  Widget _startScreen(BuildContext context, CourseDetailController ctrl) {
    final t = context.tokens;
    final course = ctrl.course!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: t.accentSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  course.category,
                  style: TextStyle(
                    color: t.accentInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                course.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                course.description,
                textAlign: TextAlign.center,
                style: TextStyle(color: t.muted, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Text(
                '${course.lessons.length} этапов'
                '${course.hasQuiz ? ' + итоговый тест' : ''}',
                style: TextStyle(color: t.faint, fontSize: 13),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ctrl.enroll(courseId),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Начать курс'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scene(BuildContext context, CourseDetailController ctrl) {
    final course = ctrl.course!;
    final lessons = course.lessons;
    final hasQuiz = course.hasQuiz;
    final nodeCount = lessons.length + (hasQuiz ? 1 : 0);
    final totalHeight = _topPad * 2 + _spacing * (nodeCount - 1) + _nodeSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final laneW = math.min(width, 460.0);
        final centerX = width / 2;
        final amp = laneW * 0.30;

        Offset pointAt(int i) {
          // Зигзаг влево-вправо вокруг центра (как в Duolingo).
          const pattern = [0.0, -0.72, 0.72, -0.55, 0.55, -0.72, 0.72];
          final f = pattern[i % pattern.length];
          return Offset(centerX + amp * f, _topPad + i * _spacing);
        }

        final points = [for (var i = 0; i < nodeCount; i++) pointAt(i)];
        // Сцена не ниже видимой области — иначе фон обрежется снизу.
        final minH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 320.0;
        final h = math.max(totalHeight, minH);

        return SingleChildScrollView(
          child: SizedBox(
            width: width,
            height: h,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _DesertPainter(seed: courseId)),
                ),
                ..._decorationPlacements(width, centerX, laneW, points),
                Positioned.fill(
                  child: CustomPaint(painter: _TrailPainter(points: points)),
                ),
                for (var i = 0; i < nodeCount; i++)
                  _positionedNode(context, ctrl, lessons, hasQuiz, points, i),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _positionedNode(
    BuildContext context,
    CourseDetailController ctrl,
    List<Lesson> lessons,
    bool hasQuiz,
    List<Offset> points,
    int i,
  ) {
    final p = points[i];
    final isQuiz = hasQuiz && i == lessons.length;

    _NodeState state;
    VoidCallback? onTap;

    if (isQuiz) {
      final unlocked = ctrl.allLessonsDone;
      state = ctrl.courseCompleted
          ? _NodeState.done
          : unlocked
          ? _NodeState.current
          : _NodeState.locked;
      onTap = unlocked
          ? () => _openQuiz(context, ctrl, ctrl.course!.title)
          : () => _lockedHint(context);
    } else {
      final lesson = lessons[i];
      final done = ctrl.isLessonDone(lesson.id);
      final unlocked = ctrl.isLessonUnlocked(i);
      state = done
          ? _NodeState.done
          : unlocked
          ? _NodeState.current
          : _NodeState.locked;
      onTap = unlocked
          ? () => _openLesson(context, ctrl, lesson, i)
          : () => _lockedHint(context);
    }

    return Positioned(
      left: p.dx - _nodeSize / 2,
      top: p.dy - _nodeSize / 2,
      width: _nodeSize,
      height: _nodeSize,
      child: _RigNode(
        state: state,
        assetKey: isQuiz ? '6' : '${i + 1}',
        // ← было 'quiz'
        isQuiz: isQuiz,
        title: isQuiz ? 'Итоговый тест' : lessons[i].title,
        onTap: onTap,
      ),
    );
  }

  void _lockedHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сначала пройдите предыдущий этап')),
    );
  }
}

const _decAssets = [
  'dec_pumpjack',
  'dec_tank',
  'dec_fueltruck',
  'dec_building',
  'dec_flare',
  'dec_towtruck',
  'dec_pickup',
  'dec_valve',
  'dec_pipes',
];

Widget _decorationImage(String name, double size) => Image.asset(
  'assets/map/$name.png',
  width: size,
  height: size,
  fit: BoxFit.contain,
  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
);

List<Widget> _decorationPlacements(
  double width,
  double centerX,
  double laneW,
  List<Offset> points,
) {
  final out = <Widget>[];
  for (var i = 0; i < points.length; i++) {
    final p = points[i];
    final side = p.dx < centerX ? 1.0 : -1.0;
    const size = 120.0;
    var x = centerX + side * (laneW * 0.5 + 44) - size / 2;
    x = x.clamp(12.0, width - size - 12);
    out.add(
      Positioned(
        left: x,
        top: p.dy - size / 2 + 14,
        child: _decorationImage(_decAssets[i % _decAssets.length], size),
      ),
    );
  }
  return out;
}

enum _NodeState { done, current, locked }

class _RigNode extends StatefulWidget {
  final _NodeState state;
  final String assetKey;
  final String title;
  final bool isQuiz;
  final VoidCallback? onTap;

  const _RigNode({
    required this.state,
    required this.assetKey,
    required this.title,
    required this.isQuiz,
    this.onTap,
  });

  @override
  State<_RigNode> createState() => _RigNodeState();
}

class _RigNodeState extends State<_RigNode> {
  bool _hover = false;
  bool _pressed = false;

  _NodeState get state => widget.state;

  String get assetKey => widget.assetKey;

  String get title => widget.title;

  bool get isQuiz => widget.isQuiz;

  VoidCallback? get onTap => widget.onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final Color fallback = switch (state) {
      _NodeState.done => t.accent,
      _NodeState.current => const Color(0xFFE0A542),
      _NodeState.locked => const Color(0xFF9E9075),
    };

    Widget rig = Image.asset(
      'assets/map/rig_$assetKey.png',
      width: _rigSize,
      height: _rigSize,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/map/rig.png',
        width: _rigSize,
        height: _rigSize,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => CustomPaint(
          size: const Size(_rigSize * 0.86, _rigSize * 0.86),
          painter: _RigPainter(body: fallback, isQuiz: isQuiz),
        ),
      ),
    );
    if (state == _NodeState.locked) {
      rig = Opacity(opacity: 0.5, child: rig);
    }

    final enabled = state != _NodeState.locked;
    final double dy = enabled ? (_pressed ? 4.0 : (_hover ? -8.0 : 0.0)) : 0.0;
    final double scale = enabled
        ? (_pressed ? 0.94 : (_hover ? 1.08 : 1.0))
        : 1.0;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTap: onTap,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, dy, 0)..scale(scale),
          transformAlignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: _nodeSize,
                height: _nodeSize - 26,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: 6,
                      child: Container(
                        width: 74,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                    if (state == _NodeState.current)
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF6C560).withOpacity(0.45),
                        ),
                      ),
                    Align(alignment: Alignment.center, child: rig),
                    Positioned(right: 20, bottom: 8, child: _badge(context)),
                  ],
                ),
              ),
              SizedBox(
                width: _nodeSize,
                child: Text(
                  isQuiz ? 'Итоговый тест' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: state == _NodeState.locked
                        ? _sandInk.withOpacity(0.5)
                        : _sandInk,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(BuildContext context) {
    final Color ring = switch (state) {
      _NodeState.done => const Color(0xFF1F9E6E),
      _NodeState.current => const Color(0xFFCE8A1F),
      _NodeState.locked => const Color(0xFF9E9075),
    };
    Widget? child;
    switch (state) {
      case _NodeState.done:
        child = Icon(Icons.check, size: 16, color: ring);
        break;
      case _NodeState.locked:
        child = Icon(Icons.lock, size: 14, color: ring);
        break;
      case _NodeState.current:
        child = isQuiz ? Icon(Icons.flag, size: 15, color: ring) : null;
        break;
    }
    if (child == null) return const SizedBox.shrink();
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 2.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TrailPainter extends CustomPainter {
  final List<Offset> points;

  _TrailPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = _trail
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
      path.lineTo(p1.dx, p1.dy);
    }
    _drawDashed(canvas, path, paint);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dash = 14.0;
    const gap = 12.0;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        final end = math.min(d + dash, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter old) => old.points != points;
}

class _RigPainter extends CustomPainter {
  final Color body;
  final bool isQuiz;

  _RigPainter({required this.body, required this.isQuiz});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = const Color(0xFF3B2F1C);
    final line = Paint()
      ..color = stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = body
      ..style = PaintingStyle.fill;

    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.64, w * 0.56, h * 0.22),
      const Radius.circular(6),
    );
    canvas.drawRRect(baseRect, fill);
    canvas.drawRRect(baseRect, line);

    final topL = Offset(w * 0.42, h * 0.14);
    final topR = Offset(w * 0.58, h * 0.14);
    final botL = Offset(w * 0.28, h * 0.64);
    final botR = Offset(w * 0.72, h * 0.64);
    canvas.drawLine(botL, topL, line);
    canvas.drawLine(botR, topR, line);
    canvas.drawLine(topL, topR, line);
    for (final f in [0.15, 0.4, 0.65]) {
      final la = Offset.lerp(botL, topL, f)!;
      final ra = Offset.lerp(botR, topR, f)!;
      final lb = Offset.lerp(botL, topL, f + 0.18)!;
      final rb = Offset.lerp(botR, topR, f + 0.18)!;
      canvas.drawLine(la, rb, line);
      canvas.drawLine(ra, lb, line);
      canvas.drawLine(la, ra, line);
    }
    final tip = Offset(w * 0.5, h * 0.14);
    canvas.drawCircle(tip, 3.4, fill);
    for (final a in [-0.5, 0.0, 0.5]) {
      canvas.drawLine(tip, tip + Offset(a * 13, -13), line);
    }
  }

  @override
  bool shouldRepaint(covariant _RigPainter old) =>
      old.body != body || old.isQuiz != isQuiz;
}

class _DesertPainter extends CustomPainter {
  final int seed;

  _DesertPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_sand, _sandDark],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    final rnd = math.Random(seed * 7 + 13);
    final count = ((size.width * size.height) / 13000).clamp(16, 500).toInt();
    for (var i = 0; i < count; i++) {
      final o = Offset(
        rnd.nextDouble() * size.width,
        20 + rnd.nextDouble() * (size.height - 40),
      );
      final r = rnd.nextDouble();
      if (r < 0.62) {
        _dune(canvas, o, 12 + rnd.nextDouble() * 26);
      } else if (r < 0.84) {
        _bush(canvas, o, 7 + rnd.nextDouble() * 6);
      } else {
        _cactus(canvas, o, 11 + rnd.nextDouble() * 10);
      }
    }
  }

  void _dune(Canvas c, Offset o, double w) {
    final base = Paint()..color = const Color(0xFFE3CB99);
    final hi = Paint()..color = const Color(0xFFF4E7CB);
    c.drawOval(Rect.fromCenter(center: o, width: w, height: w * 0.5), base);
    c.drawOval(
      Rect.fromCenter(
        center: o.translate(0, -w * 0.06),
        width: w * 0.7,
        height: w * 0.3,
      ),
      hi,
    );
  }

  void _bush(Canvas c, Offset o, double r) {
    final dark = Paint()..color = const Color(0xFF5FA23C);
    final light = Paint()..color = const Color(0xFF7CC353);
    c.drawCircle(o.translate(-r * 0.5, 0), r * 0.8, dark);
    c.drawCircle(o.translate(r * 0.5, 0), r * 0.8, dark);
    c.drawCircle(o.translate(0, -r * 0.4), r, light);
  }

  void _cactus(Canvas c, Offset o, double h) {
    final p = Paint()
      ..color = const Color(0xFF57993A)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = h * 0.32
      ..style = PaintingStyle.stroke;
    c.drawLine(o, o.translate(0, -h), p);
    final armY = -h * 0.55;
    c.drawLine(o.translate(0, armY), o.translate(h * 0.4, armY), p);
    c.drawLine(
      o.translate(h * 0.4, armY),
      o.translate(h * 0.4, armY - h * 0.35),
      p,
    );
    c.drawLine(
      o.translate(0, armY + h * 0.15),
      o.translate(-h * 0.35, armY + h * 0.15),
      p,
    );
    c.drawLine(
      o.translate(-h * 0.35, armY + h * 0.15),
      o.translate(-h * 0.35, armY - h * 0.2),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _DesertPainter old) => old.seed != seed;
}
