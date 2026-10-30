import 'package:flutter/material.dart';

const _semilla = Color(0xFF2E7D6B);

ThemeData temaClaro() => _tema(Brightness.light);

ThemeData temaOscuro() => _tema(Brightness.dark);

ThemeData _tema(Brightness brillo) {
  final colores = ColorScheme.fromSeed(seedColor: _semilla, brightness: brillo);
  return ThemeData(
    colorScheme: colores,
    useMaterial3: true,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
