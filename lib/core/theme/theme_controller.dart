import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Глобальный режим темы (system/light/dark) с сохранением в localStorage.
/// Переключается из Профиля.
class ThemeController extends ChangeNotifier {
  static const _key = 'kmge_theme';

  ThemeMode _mode;

  ThemeController() : _mode = _load();

  ThemeMode get mode => _mode;

  static ThemeMode _load() {
    switch (html.window.localStorage[_key]) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void set(ThemeMode mode) {
    _mode = mode;
    html.window.localStorage[_key] = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    notifyListeners();
  }

  void toggle(bool dark) => set(dark ? ThemeMode.dark : ThemeMode.light);
}
