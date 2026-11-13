import 'package:flutter/material.dart';

/// Colores y textos propios de cada estilo, además del esquema de Material.
@immutable
class Paleta extends ThemeExtension<Paleta> {
  const Paleta({
    required this.fondo,
    required this.tarjeta,
    required this.texto,
    required this.textoSecundario,
    required this.acento,
    required this.sobreAcento,
    required this.superficie,
    required this.detalle,
    required this.separador,
    required this.lema,
  });

  final Color fondo;
  final Color tarjeta;
  final Color texto;
  final Color textoSecundario;
  final Color acento;

  /// Texto sobre botones del color de acento.
  final Color sobreAcento;

  /// Fondo de la tarjeta destacada y de las etiquetas.
  final Color superficie;

  /// Fondo de los íconos de acceso rápido.
  final Color detalle;
  final Color separador;

  /// Título grande de la pantalla Hoy.
  final String lema;

  static Paleta de(BuildContext context) =>
      Theme.of(context).extension<Paleta>()!;

  @override
  Paleta copyWith() => this;

  @override
  Paleta lerp(Paleta? other, double t) => t < 0.5 ? this : other ?? this;
}

/// Salvia: cálida y natural, para el modo claro.
const salvia = Paleta(
  fondo: Color(0xFFF5F3ED),
  tarjeta: Color(0xFFFFFFFF),
  texto: Color(0xFF27362F),
  textoSecundario: Color(0xFF647066),
  acento: Color(0xFF426552),
  sobreAcento: Color(0xFFFFFFFF),
  superficie: Color(0xFFE5EBDF),
  detalle: Color(0xFFE9DED1),
  separador: Color(0xFFE4E1D8),
  lema: 'Lo que importa,\ncontigo.',
);

/// Nocturna: íntima y enfocada, para el modo oscuro.
const nocturna = Paleta(
  fondo: Color(0xFF171A22),
  tarjeta: Color(0xFF242834),
  texto: Color(0xFFF4F2F7),
  textoSecundario: Color(0xFFB5B8C5),
  acento: Color(0xFFC4B5FA),
  sobreAcento: Color(0xFF171A22),
  superficie: Color(0xFF333044),
  detalle: Color(0xFF333044),
  separador: Color(0xFF383D4A),
  lema: 'Todo en su\nmomento.',
);

ThemeData temaClaro() => _tema(salvia, Brightness.light, 'DM Sans');

ThemeData temaOscuro() => _tema(nocturna, Brightness.dark, 'Inter');

ThemeData _tema(Paleta p, Brightness brillo, String fuente) {
  final colores = ColorScheme.fromSeed(seedColor: p.acento, brightness: brillo)
      .copyWith(
        primary: p.acento,
        onPrimary: p.sobreAcento,
        primaryContainer: p.superficie,
        onPrimaryContainer: p.texto,
        secondaryContainer: p.superficie,
        onSecondaryContainer: p.texto,
        tertiary: p.acento,
        surface: p.fondo,
        onSurface: p.texto,
        onSurfaceVariant: p.textoSecundario,
        surfaceContainerLowest: p.tarjeta,
        surfaceContainerLow: p.tarjeta,
        surfaceContainer: p.tarjeta,
        surfaceContainerHigh: p.tarjeta,
        surfaceContainerHighest: p.superficie,
        outline: p.textoSecundario,
        outlineVariant: p.separador,
      );
  final base = ThemeData(
    colorScheme: colores,
    brightness: brillo,
    fontFamily: fuente,
    useMaterial3: true,
  );
  final texto = base.textTheme.apply(bodyColor: p.texto, displayColor: p.texto);
  const radio = BorderRadius.all(Radius.circular(24));

  return base.copyWith(
    scaffoldBackgroundColor: p.fondo,
    extensions: [p],
    textTheme: texto.copyWith(
      displaySmall: texto.displaySmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.1,
        letterSpacing: -0.5,
      ),
      headlineMedium: texto.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: texto.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: texto.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: texto.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: texto.bodyMedium?.copyWith(color: p.textoSecundario),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.fondo,
      foregroundColor: p.texto,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: texto.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      color: p.tarjeta,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: radio,
        side: brillo == Brightness.light
            ? BorderSide(color: p.separador.withValues(alpha: 0.6))
            : BorderSide.none,
      ),
    ),
    listTileTheme: ListTileThemeData(
      shape: const RoundedRectangleBorder(borderRadius: radio),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      iconColor: p.textoSecundario,
      subtitleTextStyle: texto.bodyMedium?.copyWith(color: p.textoSecundario),
    ),
    dividerTheme: DividerThemeData(color: p.separador, thickness: 1, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.acento,
        foregroundColor: p.sobreAcento,
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.texto,
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        side: BorderSide(color: p.separador),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.acento,
      foregroundColor: p.sobreAcento,
      elevation: 1,
      shape: const StadiumBorder(),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.tarjeta,
      selectedColor: p.superficie,
      side: BorderSide(color: p.separador),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(color: p.texto, fontFamily: fuente),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: const CircleBorder(),
      side: BorderSide(color: p.textoSecundario, width: 1.5),
      fillColor: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.selected) ? p.acento : null,
      ),
      checkColor: WidgetStatePropertyAll(p.sobreAcento),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.tarjeta,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: p.separador),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: p.separador),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: p.acento, width: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.fondo,
      surfaceTintColor: Colors.transparent,
      indicatorColor: p.superficie,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (estados) => TextStyle(
          fontFamily: fuente,
          fontSize: 13,
          fontWeight: estados.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w500,
          color: estados.contains(WidgetState.selected)
              ? p.texto
              : p.textoSecundario,
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.tarjeta,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
    dialogTheme: DialogThemeData(backgroundColor: p.tarjeta),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.texto,
      contentTextStyle: TextStyle(color: p.fondo, fontFamily: fuente),
      shape: const StadiumBorder(),
    ),
  );
}
