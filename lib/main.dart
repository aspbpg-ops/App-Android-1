import 'package:asistente_app/app/app.dart';
import 'package:asistente_app/core/datos/almacen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [almacenProvider.overrideWithValue(AlmacenLocal(prefs))],
      child: const AsistenteApp(),
    ),
  );
}
