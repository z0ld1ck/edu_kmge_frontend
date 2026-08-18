import 'package:flutter/material.dart';

/// Семантические токены дизайна (свет/тёмная), доступны через `context.tokens`.
///
/// Экраны берут цвета отсюда, а не из хардкода — тогда тёмная тема работает
/// автоматически. Соответствует дизайн-концепту KMGE Edu.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color muted;
  final Color faint;
  final Color accent;
  final Color accentInk;
  final Color accentSoft;
  final Color amber;
  final Color amberSoft;
  final Color danger;
  final Color dangerSoft;
  final Color info;
  final Color infoSoft;
  final Color ringTrack;

  const AppTokens({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.muted,
    required this.faint,
    required this.accent,
    required this.accentInk,
    required this.accentSoft,
    required this.amber,
    required this.amberSoft,
    required this.danger,
    required this.dangerSoft,
    required this.info,
    required this.infoSoft,
    required this.ringTrack,
  });

  static const light = AppTokens(
    bg: Color(0xFFF4F7F5),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFEDF3F0),
    surface3: Color(0xFFF8FBF9),
    border: Color(0xFFE2EAE6),
    borderStrong: Color(0xFFD2DED8),
    text: Color(0xFF15211D),
    muted: Color(0xFF61726B),
    faint: Color(0xFF8A9993),
    accent: Color(0xFF0E9C77),
    accentInk: Color(0xFF0A6B52),
    accentSoft: Color(0xFFE2F3EC),
    amber: Color(0xFFC9871F),
    amberSoft: Color(0xFFFAEED6),
    danger: Color(0xFFD8452F),
    dangerSoft: Color(0xFFFBE4DF),
    info: Color(0xFF2F72BE),
    infoSoft: Color(0xFFE4EEF9),
    ringTrack: Color(0xFFE5EDE9),
  );

  static const dark = AppTokens(
    bg: Color(0xFF0D1411),
    surface: Color(0xFF151F1B),
    surface2: Color(0xFF1C2823),
    surface3: Color(0xFF111A16),
    border: Color(0xFF26332E),
    borderStrong: Color(0xFF33443D),
    text: Color(0xFFE9F1ED),
    muted: Color(0xFF9CB0A8),
    faint: Color(0xFF6F827B),
    accent: Color(0xFF2BBB90),
    accentInk: Color(0xFF7EE3C6),
    accentSoft: Color(0xFF172A24),
    amber: Color(0xFFE0A542),
    amberSoft: Color(0xFF322813),
    danger: Color(0xFFEC6A54),
    dangerSoft: Color(0xFF33201C),
    info: Color(0xFF5B9BE0),
    infoSoft: Color(0xFF1B2A3B),
    ringTrack: Color(0xFF26332E),
  );

  @override
  AppTokens copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? surface3,
    Color? border,
    Color? borderStrong,
    Color? text,
    Color? muted,
    Color? faint,
    Color? accent,
    Color? accentInk,
    Color? accentSoft,
    Color? amber,
    Color? amberSoft,
    Color? danger,
    Color? dangerSoft,
    Color? info,
    Color? infoSoft,
    Color? ringTrack,
  }) {
    return AppTokens(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      faint: faint ?? this.faint,
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      accentSoft: accentSoft ?? this.accentSoft,
      amber: amber ?? this.amber,
      amberSoft: amberSoft ?? this.amberSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      ringTrack: ringTrack ?? this.ringTrack,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      faint: Color.lerp(faint, other.faint, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      amberSoft: Color.lerp(amberSoft, other.amberSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      ringTrack: Color.lerp(ringTrack, other.ringTrack, t)!,
    );
  }
}

extension AppTokensX on BuildContext {
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.light;
}

/// Обратная совместимость: старый код ссылается на AppColors.brand и т.д.
/// Это статические (не адаптивные) значения — новые экраны должны использовать
/// `context.tokens`. Оставлено, чтобы не ломать сборку при постепенной миграции.
class AppColors {
  static const brand = Color(0xFF0E9C77);
  static const brandLight = Color(0xFF2BBB90);
  static const background = Color(0xFFF4F7F5);
}

ThemeData buildLightTheme() => _buildTheme(AppTokens.light, Brightness.light);
ThemeData buildDarkTheme() => _buildTheme(AppTokens.dark, Brightness.dark);

ThemeData _buildTheme(AppTokens t, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: t.accent,
    brightness: brightness,
  ).copyWith(
    primary: t.accent,
    onPrimary: Colors.white,
    secondary: t.accent,
    onSecondary: Colors.white,
    surface: t.surface,
    onSurface: t.text,
    error: t.danger,
    onError: Colors.white,
    outline: t.border,
    outlineVariant: t.border,
  );

  final base = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    colorScheme: scheme,
  );

  final radius = BorderRadius.circular(16);

  return base.copyWith(
    scaffoldBackgroundColor: t.bg,
    canvasColor: t.surface,
    extensions: [t],
    dividerColor: t.border,
    dividerTheme: DividerThemeData(color: t.border, thickness: 1, space: 1),
    iconTheme: IconThemeData(color: t.muted),
    textTheme: base.textTheme.apply(bodyColor: t.text, displayColor: t.text),
    appBarTheme: AppBarTheme(
      backgroundColor: t.surface,
      foregroundColor: t.text,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: t.text,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: t.muted),
    ),
    // Если flutter analyze ругнётся на CardThemeData / TabBarThemeData —
    // у вас старый Flutter: замените их на CardTheme / TabBarTheme.
    cardTheme: CardThemeData(
      color: t.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: t.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: t.accent,
        foregroundColor: Colors.white,
        disabledBackgroundColor: t.borderStrong,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.01),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: t.text,
        side: BorderSide(color: t.borderStrong),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle:
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: t.accentInk,
        textStyle:
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surface,
      hintStyle: TextStyle(color: t.faint),
      labelStyle: TextStyle(color: t.muted),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: t.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: t.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: t.accent, width: 1.6),
      ),
      prefixIconColor: t.faint,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: t.surface2,
      side: BorderSide.none,
      labelStyle: TextStyle(
          color: t.muted, fontSize: 12.5, fontWeight: FontWeight.w600),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? Colors.white : t.faint),
      trackColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? t.accent : t.surface2),
      trackOutlineColor: WidgetStateProperty.all(t.border),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? t.accent : t.faint),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: t.accent,
      linearTrackColor: t.ringTrack,
      circularTrackColor: t.ringTrack,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: t.accentInk,
      unselectedLabelColor: t.muted,
      indicatorColor: t.accent,
      dividerColor: t.border,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: t.muted,
      textColor: t.text,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: t.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: t.border),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: t.text,
      contentTextStyle: TextStyle(color: t.bg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
