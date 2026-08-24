// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../di/injection.dart';
import '../network/api_client.dart';
import '../theme/app_theme.dart';

/// Открыть PDF во встроенном окне приложения (авторизованный запрос → blob).
Future<void> showPdfViewer(
    BuildContext context, {
      required String apiPath,
      required String title,
    }) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => PdfViewerDialog(apiPath: apiPath, title: title),
  );
}

class PdfViewerDialog extends StatefulWidget {
  final String apiPath;
  final String title;
  const PdfViewerDialog({super.key, required this.apiPath, required this.title});

  @override
  State<PdfViewerDialog> createState() => _PdfViewerDialogState();
}

class _PdfViewerDialogState extends State<PdfViewerDialog> {
  static int _seq = 0;
  late final String _viewType = 'pdf-view-${_seq++}';
  String? _blobUrl;
  String? _error;
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final bytes = await sl<ApiClient>().getBytes(widget.apiPath);
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
        final el = html.IFrameElement()
          ..src = url
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return el;
      });
      setState(() {
        _blobUrl = url;
        _registered = true;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    if (_blobUrl != null) html.Url.revokeObjectUrl(_blobUrl!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final size = MediaQuery.of(context).size;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: size.width * 0.9,
        height: size.height * 0.9,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              decoration: BoxDecoration(
                color: t.surface,
                border: Border(bottom: BorderSide(color: t.border)),
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf_outlined, color: t.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: t.text)),
                  ),
                  IconButton(
                    tooltip: 'Открыть в новой вкладке',
                    icon: Icon(Icons.open_in_new, size: 20, color: t.muted),
                    onPressed: _blobUrl == null
                        ? null
                        : () => html.window.open(_blobUrl!, '_blank'),
                  ),
                  IconButton(
                    tooltip: 'Закрыть',
                    icon: Icon(Icons.close, color: t.muted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _error != null
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Не удалось открыть файл: $_error',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: t.danger)),
                ),
              )
                  : _registered
                  ? HtmlElementView(viewType: _viewType)
                  : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
