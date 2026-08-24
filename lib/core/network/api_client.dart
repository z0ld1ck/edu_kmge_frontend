import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'failure.dart';

/// Тонкая обёртка над http: подстановка токена, разбор JSON и ошибок,
/// скачивание файлов в вебе. Используется датасорсами всех фич.
class ApiClient {
  final TokenStorage _tokenStorage;
  final http.Client _http;

  ApiClient(this._tokenStorage, [http.Client? client])
    : _http = client ?? http.Client();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final q = query?.map((k, v) => MapEntry(k, '$v'))
      ?..removeWhere((_, v) => v == 'null');
    return Uri.parse(
      '${AppConfig.apiBase}$path',
    ).replace(queryParameters: q == null || q.isEmpty ? null : q);
  }

  Map<String, String> _headers({bool json = true}) => {
    if (json) 'Content-Type': 'application/json',
    if (_tokenStorage.token != null)
      'Authorization': 'Bearer ${_tokenStorage.token}',
  };

  dynamic _decode(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) {
      if (r.bodyBytes.isEmpty) return null;
      return jsonDecode(utf8.decode(r.bodyBytes));
    }
    throw Failure(_extractError(r), statusCode: r.statusCode);
  }

  String _extractError(http.Response r) {
    try {
      final body = jsonDecode(utf8.decode(r.bodyBytes));
      final detail = body is Map ? body['detail'] : null;
      if (detail is String) return detail;
      if (detail is List) {
        return detail.map((e) => e is Map ? (e['msg'] ?? e) : e).join(', ');
      }
    } catch (_) {}
    return 'Ошибка ${r.statusCode}';
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async =>
      _decode(await _http.get(_uri(path, query), headers: _headers()));

  Future<dynamic> post(String path, {Object? body}) async => _decode(
    await _http.post(
      _uri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    ),
  );

  /// Отправка формы (application/x-www-form-urlencoded) — для OAuth2-логина.
  Future<dynamic> postForm(String path, Map<String, String> fields) async =>
      _decode(
        await _http.post(
          _uri(path),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (_tokenStorage.token != null)
              'Authorization': 'Bearer ${_tokenStorage.token}',
          },
          body: fields,
        ),
      );

  Future<dynamic> patch(String path, {Object? body}) async => _decode(
    await _http.patch(
      _uri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    ),
  );

  Future<dynamic> put(String path, {Object? body}) async => _decode(
    await _http.put(
      _uri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    ),
  );

  Future<dynamic> delete(String path) async =>
      _decode(await _http.delete(_uri(path), headers: _headers()));

  /// Получить сырые байты (для встроенного просмотра PDF через blob).
  Future<Uint8List> getBytes(String path) async {
    final r = await _http.get(_uri(path), headers: _headers(json: false));
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Failure(_extractError(r), statusCode: r.statusCode);
    }
    return r.bodyBytes;
  }

  /// Загрузка файла (multipart/form-data) с авторизацией.
  Future<dynamic> uploadFile(
    String path, {
    required List<int> bytes,
    required String filename,
    Map<String, String> fields = const {},
  }) async {
    final req = http.MultipartRequest('POST', _uri(path));
    if (_tokenStorage.token != null) {
      req.headers['Authorization'] = 'Bearer ${_tokenStorage.token}';
    }
    req.fields.addAll(fields);
    req.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );
    final streamed = await _http.send(req);
    final r = await http.Response.fromStream(streamed);
    return _decode(r);
  }

  /// Скачивание файла (PDF/XLSX) в браузере с авторизацией через blob.
  Future<void> download(String path, String filename) async {
    final r = await _http.get(_uri(path), headers: _headers(json: false));
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Failure(_extractError(r), statusCode: r.statusCode);
    }
    final url = html.Url.createObjectUrlFromBlob(html.Blob([r.bodyBytes]));
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
