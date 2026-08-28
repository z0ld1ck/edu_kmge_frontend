import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';
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
            mainAxisExtent: 270,
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
        const SizedBox(width: 10),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: ctrl.category,
              isDense: true,
              borderRadius: BorderRadius.circular(14),
              icon: Icon(Icons.expand_more, size: 18, color: t.muted),
              style: TextStyle(color: t.text, fontSize: 13.5),
              dropdownColor: t.surface,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Все направления'),
                ),
                for (final c in ctrl.categories)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: ctrl.setCategory,
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/courses/${course.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: _cover(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.25,
                      fontWeight: FontWeight.bold,
                      color: t.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Flexible(child: _CategoryChip(course.category)),
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color:Colors.black, fontSize: 25)),
                      const SizedBox(width: 8),
                      Icon(Icons.menu_book_outlined, size: 15, color: t.faint),
                      const SizedBox(width: 4),
                      Text('${course.lessonsCount} уроков',
                          style: TextStyle(color: t.muted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cover(BuildContext context) {
    final url = course.coverUrl;
    if (url != null && url.isNotEmpty) {
      final full = url.startsWith('http') ? url : '${AppConfig.apiBase}$url';
      return Image.network(
        full,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    final pair = _gradientFor(course.category);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: pair,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.school_outlined,
          size: 42,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  static List<Color> _gradientFor(String category) {
    const palettes = [
      [Color(0xFF6D8DFF), Color(0xFF4C63D2)],
      [Color(0xFF34C7A9), Color(0xFF2A9D8F)],
      [Color(0xFFF6A94A), Color(0xFFE07B39)],
      [Color(0xFFEF6F8B), Color(0xFFD64570)],
      [Color(0xFF7E71E8), Color(0xFF5B4CC4)],
      [Color(0xFF5AB0E0), Color(0xFF3277B8)],
    ];
    return palettes[category.hashCode.abs() % palettes.length];
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip(this.label);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: t.accentInk,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
