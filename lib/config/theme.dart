import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════
/// ENERGO — Palette officielle (charte graphique)
/// Miroir exact de assets/css/main.css (energo_pwa)
///
///   Rich Black #021B1A · Dark Green #032221
///   Pine #06302B · Basil #08453A · Forest #095544
///   Bangladesh Green #03624C · Frog #17876D
///   Mountain Meadow #2CC295 · Caribbean Green #00DF81
///   Mint #2FA98C · Stone #707D7D · Pistachio #AACBC4
///   Anti-Flash White #F1F7F6
/// ═══════════════════════════════════════════════════════════

class AppColors {
  // ── MODE SOMBRE (défaut) ──────────────────────────────────
  static const primaryDark    = Color(0xFF00DF81); // Caribbean Green
  static const primaryDarkAlt = Color(0xFF2CC295); // Mountain Meadow (hover)
  static const blackDark      = Color(0xFF021B1A); // Rich Black — fond général
  static const surface900Dark = Color(0xFF032221); // Dark Green — topbar/nav
  static const surface800Dark = Color(0xFF06302B); // Pine — cartes/inputs
  static const surface700Dark = Color(0xFF08453A); // Basil — bordures
  static const gray500        = Color(0xFF707D7D); // Stone
  static const gray400Dark    = Color(0xFF9DB5B1); // Stone éclairci
  static const gray200Dark    = Color(0xFFD3E4E0);
  static const whiteDark      = Color(0xFFF1F7F6); // Anti-Flash White — texte
  static const greenDark      = Color(0xFF2CC295); // Mountain Meadow
  static const redDark        = Color(0xFFFF6B6B);
  static const orangeDark     = Color(0xFFF5A524);

  // ── MODE CLAIR ─────────────────────────────────────────────
  static const primaryLight    = Color(0xFF00DF81); // Caribbean Green conservé
  static const primaryLightAlt = Color(0xFF17876D); // Frog (hover plus profond)
  static const blackLight      = Color(0xFFF1F7F6); // fond général → blanc cassé
  static const surface900Light = Color(0xFFFFFFFF); // topbar/nav → blanc
  static const surface800Light = Color(0xFFFFFFFF); // cartes/inputs → blanc
  static const surface700Light = Color(0xFFC9DBD6); // bordures → Pistachio foncé
  static const gray400Light    = Color(0xFF5C6E6B); // Stone assombri
  static const gray200Light    = Color(0xFF06302B);
  static const whiteLight      = Color(0xFF032221); // texte principal → Dark Green
  static const greenLight      = Color(0xFF17876D); // Frog (contraste sur blanc)
  static const redLight        = Color(0xFFD64545);
  static const orangeLight     = Color(0xFFC77F17);

  // ── Communes aux deux thèmes ───────────────────────────────
  static const mtn    = Color(0xFFFFCC00);
  static const airtel = Color(0xFFE40000);
  static const blue   = Color(0xFF0A84FF);
}

/// Accès rapide aux couleurs du thème courant, pour éviter de
/// répéter Theme.of(context).extension<...> partout dans l'UI.
/// Usage : final c = context.energoColors;  →  c.primary, c.surface...
class EnergoColors extends ThemeExtension<EnergoColors> {
  final Color primary;
  final Color primaryAlt;
  final Color background;
  final Color surface900;
  final Color surface800;
  final Color surface700;
  final Color textPrimary;
  final Color textSecondary;
  final Color green;
  final Color red;
  final Color orange;

  const EnergoColors({
    required this.primary,
    required this.primaryAlt,
    required this.background,
    required this.surface900,
    required this.surface800,
    required this.surface700,
    required this.textPrimary,
    required this.textSecondary,
    required this.green,
    required this.red,
    required this.orange,
  });

  static const dark = EnergoColors(
    primary: AppColors.primaryDark,
    primaryAlt: AppColors.primaryDarkAlt,
    background: AppColors.blackDark,
    surface900: AppColors.surface900Dark,
    surface800: AppColors.surface800Dark,
    surface700: AppColors.surface700Dark,
    textPrimary: AppColors.whiteDark,
    textSecondary: AppColors.gray400Dark,
    green: AppColors.greenDark,
    red: AppColors.redDark,
    orange: AppColors.orangeDark,
  );

  static const light = EnergoColors(
    primary: AppColors.primaryLight,
    primaryAlt: AppColors.primaryLightAlt,
    background: AppColors.blackLight,
    surface900: AppColors.surface900Light,
    surface800: AppColors.surface800Light,
    surface700: AppColors.surface700Light,
    textPrimary: AppColors.whiteLight,
    textSecondary: AppColors.gray400Light,
    green: AppColors.greenLight,
    red: AppColors.redLight,
    orange: AppColors.orangeLight,
  );

  @override
  EnergoColors copyWith({
    Color? primary,
    Color? primaryAlt,
    Color? background,
    Color? surface900,
    Color? surface800,
    Color? surface700,
    Color? textPrimary,
    Color? textSecondary,
    Color? green,
    Color? red,
    Color? orange,
  }) {
    return EnergoColors(
      primary: primary ?? this.primary,
      primaryAlt: primaryAlt ?? this.primaryAlt,
      background: background ?? this.background,
      surface900: surface900 ?? this.surface900,
      surface800: surface800 ?? this.surface800,
      surface700: surface700 ?? this.surface700,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      green: green ?? this.green,
      red: red ?? this.red,
      orange: orange ?? this.orange,
    );
  }

  @override
  EnergoColors lerp(ThemeExtension<EnergoColors>? other, double t) {
    if (other is! EnergoColors) return this;
    return EnergoColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryAlt: Color.lerp(primaryAlt, other.primaryAlt, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface900: Color.lerp(surface900, other.surface900, t)!,
      surface800: Color.lerp(surface800, other.surface800, t)!,
      surface700: Color.lerp(surface700, other.surface700, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      green: Color.lerp(green, other.green, t)!,
      red: Color.lerp(red, other.red, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
    );
  }
}

extension EnergoColorsContext on BuildContext {
  EnergoColors get energoColors =>
      Theme.of(this).extension<EnergoColors>() ?? EnergoColors.dark;
}

class AppTheme {
  static ThemeData _build(EnergoColors c, Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: c.background,
      primaryColor: c.primary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.primary,
        onPrimary: brightness == Brightness.dark ? Colors.black : Colors.white,
        secondary: c.primaryAlt,
        onSecondary: Colors.black,
        surface: c.surface800,
        onSurface: c.textPrimary,
        error: c.red,
        onError: Colors.white,
      ),
      extensions: [c],
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface900,
        foregroundColor: c.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: brightness == Brightness.dark ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          side: BorderSide(color: c.surface700),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.surface700, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.surface700, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: c.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: c.surface800,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.surface700),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.surface700),
    );
  }

  static ThemeData get dark => _build(EnergoColors.dark, Brightness.dark);
  static ThemeData get light => _build(EnergoColors.light, Brightness.light);
}