import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Кастомный SVG-набор иконок приложения (штриховые 24×24, перекрашиваются).
class AppIcons {
  static const String _head =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
      'fill="none" stroke="#000" stroke-width="1.7" '
      'stroke-linecap="round" stroke-linejoin="round">';

  static String _w(String body) => '$_head$body</svg>';

  static final Map<String, String> pack = {
    'home': _w(
        '<path d="M4 10.5 12 4l8 6.5"/><path d="M6 9v10a1 1 0 0 0 1 1h3v-6h4v6h3a1 1 0 0 0 1-1V9"/>'),
    'book': _w(
        '<path d="M12 6c-1.6-1-4-1.5-6-1.5S3 5 3 5v13s1.4-.6 3.4-.6S12 19 12 19m0-13c1.6-1 4-1.5 6-1.5S21 5 21 5v13s-1.4-.6-3.4-.6S12 19 12 19m0-13v13"/>'),
    'award': _w(
        '<circle cx="12" cy="9" r="5"/><path d="M8.5 13.4 7 21l5-2.6L17 21l-1.5-7.6"/>'),
    'grid': _w(
        '<rect x="4" y="4" width="7" height="7" rx="1.6"/><rect x="13" y="4" width="7" height="7" rx="1.6"/><rect x="4" y="13" width="7" height="7" rx="1.6"/><rect x="13" y="13" width="7" height="7" rx="1.6"/>'),
    'users': _w(
        '<circle cx="9" cy="8" r="3.2"/><path d="M3.5 20c0-3 2.5-5.2 5.5-5.2S14.5 17 14.5 20"/><path d="M16 5.2a3.2 3.2 0 0 1 0 5.7"/><path d="M17.6 15c2 .6 3.4 2.4 3.4 5"/>'),
    'clipboard': _w(
        '<rect x="5" y="4.5" width="14" height="16" rx="2.2"/><path d="M9 4.5v-1a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v1"/><path d="m9 13 2 2 4-4"/>'),
    'logout': _w(
        '<path d="M9 4H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h3"/><path d="m16 17 5-5-5-5"/><path d="M21 12H9"/>'),
    'search': _w('<circle cx="11" cy="11" r="6.5"/><path d="m20 20-3.6-3.6"/>'),
    'bell': _w(
        '<path d="M18 8a6 6 0 1 0-12 0c0 6-2 7-2 7h16s-2-1-2-7"/><path d="M10.4 20a2 2 0 0 0 3.2 0"/>'),
    'settings': _w(
        '<circle cx="12" cy="12" r="3"/><path d="M12 2.5v3M12 18.5v3M2.5 12h3M18.5 12h3M5.1 5.1l2.1 2.1M16.8 16.8l2.1 2.1M18.9 5.1l-2.1 2.1M7.2 16.8l-2.1 2.1"/>'),
    'user': _w(
        '<circle cx="12" cy="8.5" r="3.5"/><path d="M5.5 20c0-3.4 3-6 6.5-6s6.5 2.6 6.5 6"/>'),
    'calendar': _w(
        '<rect x="4" y="5" width="16" height="16" rx="2.2"/><path d="M4 9.5h16M8.5 3v4M15.5 3v4"/>'),
  };

  const AppIcons._();
}

/// Виджет иконки из [AppIcons.pack] с нужным цветом/размером.
class AppIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  const AppIcon(this.name, {super.key, this.size = 22, required this.color});

  @override
  Widget build(BuildContext context) {
    final svg = AppIcons.pack[name] ?? AppIcons.pack['grid']!;
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}