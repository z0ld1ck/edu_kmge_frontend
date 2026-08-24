// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../theme/app_theme.dart';

/// Рендер Markdown-контента урока в едином стиле приложения.
class MarkdownView extends StatelessWidget {
  final String data;
  final bool selectable;

  const MarkdownView(this.data, {super.key, this.selectable = true});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final sheet = MarkdownStyleSheet(
      p: TextStyle(fontSize: 15, height: 1.6, color: t.text),
      h1: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: t.text,
        height: 1.3,
      ),
      h2: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: t.text,
        height: 1.3,
      ),
      h3: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: t.text,
        height: 1.3,
      ),
      listBullet: TextStyle(fontSize: 15, color: t.text),
      strong: TextStyle(fontWeight: FontWeight.bold, color: t.text),
      em: TextStyle(fontStyle: FontStyle.italic, color: t.text),
      blockquote: TextStyle(color: t.muted, fontSize: 15, height: 1.6),
      blockquoteDecoration: BoxDecoration(
        color: t.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: t.accent, width: 3)),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13.5,
        color: t.accentInk,
        backgroundColor: t.surface2,
      ),
      codeblockDecoration: BoxDecoration(
        color: t.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.border),
      ),
      codeblockPadding: const EdgeInsets.all(14),
      a: TextStyle(
        color: t.accentInk,
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w500,
      ),
      tableHead: TextStyle(fontWeight: FontWeight.bold, color: t.text),
      tableBody: TextStyle(color: t.text, fontSize: 14),
      tableBorder: TableBorder.all(color: t.border),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.border)),
      ),
    );

    return MarkdownBody(
      data: data,
      selectable: selectable,
      styleSheet: sheet,
      imageBuilder: (uri, title, alt) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          uri.toString(),
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => Container(
            padding: const EdgeInsets.all(12),
            color: t.surface2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image_outlined, size: 18, color: t.faint),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    alt ?? 'Изображение недоступно',
                    style: TextStyle(color: t.faint, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onTapLink: (text, href, title) {
        if (href != null && href.isNotEmpty) html.window.open(href, '_blank');
      },
    );
  }
}
