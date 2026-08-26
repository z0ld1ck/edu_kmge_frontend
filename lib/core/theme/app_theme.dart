import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Семантические токены дизайна (свет/тёмная), доступны через `context.tokens`.
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
  final Color success; // прогресс всегда зелёный
  final Color amber;
  final Color amberSoft;
  final Color danger;
  final Color dangerSoft;
  final Color info;
  final Color infoSoft;
  final Color ringTrack;
  final Color navSelected;
  final Color navSelectedInk;

  const AppTokens({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.border,
    required this.success,
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
    required this.navSelected,
    required this.navSelectedInk,
  });

  static const light = AppTokens(
    bg: Color(0xFFF6F1E9),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF1EBE0),
    surface3: Color(0xFFFAF7F1),
    border: Color(0xFFEBE3D6),
    borderStrong: Color(0xFFDCD1BF),
    text: Color(0xFF111114),
    muted: Color(0xFF5B554E),
    faint: Color(0xFF938A7C),
    accent: Color(0xFF16130F),
    accentInk: Color(0xFF16130F),
    accentSoft: Color(0xFFEDE7DC),
    success: Color(0xFF2E9E5B),
    amber: Color(0xFFB5811C),
    amberSoft: Color(0xFFF6ECD3),
    danger: Color(0xFFD8452F),
    dangerSoft: Color(0xFFFBE1DB),
    info: Color(0xFF2F72BE),
    infoSoft: Color(0xFFE4EDF8),
    ringTrack: Color(0xFFEDE5D8),
    navSelected: Color(0xFF241F1B),
    navSelectedInk: Color(0xFFFFFFFF),
  );

  static const dark = AppTokens(
    bg: Color(0xFF191512),
    surface: Color(0xFF221D19),
    surface2: Color(0xFF2B251F),
    surface3: Color(0xFF15110E),
    border: Color(0xFF322B24),
    borderStrong: Color(0xFF463C32),
    text: Color(0xFFF0E9E0),
    muted: Color(0xFFB1A596),
    faint: Color(0xFF7F7568),
    accent: Color(0xFFF0E9E0),
    accentInk: Color(0xFFF0E9E0),
    accentSoft: Color(0xFF2B251F),
    success: Color(0xFF4CC479),
    amber: Color(0xFFE0A542),
    amberSoft: Color(0xFF322813),
    danger: Color(0xFFEC6A54),
    dangerSoft: Color(0xFF33201C),
    info: Color(0xFF5B9BE0),
    infoSoft: Color(0xFF1B2A3B),
    ringTrack: Color(0xFF322B24),
    navSelected: Color(0xFFF0E9E0),
    navSelectedInk: Color(0xFF191512),
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
    Color? success,
    Color? infoSoft,
    Color? ringTrack,
    Color? navSelected,
    Color? navSelectedInk,
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
      success: success ?? this.success,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      ringTrack: ringTrack ?? this.ringTrack,
      navSelected: navSelected ?? this.navSelected,
      navSelectedInk: navSelectedInk ?? this.navSelectedInk,
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
      success: Color.lerp(success, other.success, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      ringTrack: Color.lerp(ringTrack, other.ringTrack, t)!,
      navSelected: Color.lerp(navSelected, other.navSelected, t)!,
      navSelectedInk: Color.lerp(navSelectedInk, other.navSelectedInk, t)!,
    );
  }
}

extension AppTokensX on BuildContext {
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.light;
}

class AppColors {
  static const brand = Color(0xFFEC5B4C);
  static const brandLight = Color(0xFFF26D5B);
  static const background = Color(0xFFF6F1E9);
}

ThemeData buildLightTheme() => _buildTheme(AppTokens.light, Brightness.light);
ThemeData buildDarkTheme() => _buildTheme(AppTokens.dark, Brightness.dark);

ThemeData _buildTheme(AppTokens t, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: t.accent,
    brightness: brightness,
  ).copyWith(
    primary: t.accent,
    onPrimary: t.surface,
    secondary: t.accent,
    onSecondary: t.surface,
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
    fontFamily: GoogleFonts.urbanist().fontFamily,
  );

  final cardRadius = BorderRadius.circular(20);
  final btnRadius = BorderRadius.circular(14);
  final fieldRadius = BorderRadius.circular(14);

  return base.copyWith(
    scaffoldBackgroundColor: t.bg,
    canvasColor: t.surface,
    extensions: [t],
    dividerColor: t.border,
    dividerTheme: DividerThemeData(color: t.border, thickness: 1, space: 1),
    iconTheme: IconThemeData(color: t.muted),
    textTheme: base.textTheme.apply(bodyColor: t.text, displayColor: t.text),
    appBarTheme: AppBarTheme(
      backgroundColor: t.bg,
      foregroundColor: t.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: t.text,
        fontSize: 19,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: t.muted),
    ),
    cardTheme: CardThemeData(
      color: t.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: BorderSide(color: t.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: t.accent,
        foregroundColor: t.surface,
        disabledBackgroundColor: t.borderStrong,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        textStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.01),
        shape: RoundedRectangleBorder(borderRadius: btnRadius),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: t.text,
        side: BorderSide(color: t.borderStrong),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle:
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: btnRadius),
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
      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: t.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: t.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: t.border),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: t.text,
      contentTextStyle: TextStyle(color: t.bg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}