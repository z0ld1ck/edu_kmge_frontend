import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../domain/entities/course.dart';
import '../controllers/catalog_controller.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<CatalogController>()..load(),
      child: const _CatalogView(),
    );
  }
}

class _CatalogView extends StatelessWidget {
  const _CatalogView();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CatalogController>();
    return AppShell(
      title: 'Каталог курсов',
      current: '/catalog',
      search: _SearchControls(ctrl: ctrl),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: _buildBody(context, ctrl),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CatalogController ctrl) {
    if (ctrl.loading) return const Center(child: CircularProgressIndicator());
    if (ctrl.error != null) return Center(child: Text('Ошибка: ${ctrl.error}'));
    if (ctrl.courses.isEmpty) {
      return const Center(child: Text('Курсы не найдены'));
    }
    return LayoutBuilder(
      builder: (context, c) {
        final cols = (c.maxWidth / 340).floor().clamp(1, 4);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisExtent: 230,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: ctrl.courses.length,
          itemBuilder: (c, i) => _CourseCard(course: ctrl.courses[i]),
        );
      },
    );
  }
}

/// Компактный поиск + фильтр направления для верхней панели.
class _SearchControls extends StatelessWidget {
  final CatalogController ctrl;

  const _SearchControls({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final pill = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: t.border),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 260,
          height: 42,
          child: TextField(
            onChanged: ctrl.setQuery,
            onSubmitted: ctrl.setQuery,
            style: TextStyle(color: t.text, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Поиск курсов…',
              isDense: true,
              filled: true,
              fillColor: t.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              prefixIcon: Icon(Icons.search, size: 19, color: t.faint),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              hintStyle: TextStyle(color: t.faint, fontSize: 13.5),
              border: pill,
              enabledBorder: pill,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: t.accent, width: 1.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/courses/${course.id}'),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryChip(course.category),
              const SizedBox(height: 12),
              Text(
                course.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  course.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: t.muted, fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.menu_book_outlined, size: 16, color: t.faint),
                  const SizedBox(width: 4),
                  Text(
                    '${course.lessonsCount} уроков',
                    style: TextStyle(color: t.muted, fontSize: 12),
                  ),
                  if (course.hasQuiz) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.quiz_outlined, size: 16, color: t.faint),
                    const SizedBox(width: 4),
                    Text(
                      'тест',
                      style: TextStyle(color: t.muted, fontSize: 12),
                    ),
                  ],
                  const Spacer(),
                  Icon(Icons.arrow_forward, size: 18, color: t.accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip(this.label);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: t.accentSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: t.accentInk,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
