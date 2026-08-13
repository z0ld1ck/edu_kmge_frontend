// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Хранилище JWT-токена в localStorage браузера (Flutter Web).
class TokenStorage {
  static const _key = 'kmge_token';

  String? _cached;

  String? get token {
    _cached ??= html.window.localStorage[_key];
    return _cached;
  }

  void save(String token) {
    _cached = token;
    html.window.localStorage[_key] = token;
  }

  void clear() {
    _cached = null;
    html.window.localStorage.remove(_key);
  }
}
