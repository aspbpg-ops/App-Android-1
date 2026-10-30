import 'package:asistente_app/app/router.dart';
import 'package:asistente_app/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsistenteApp extends ConsumerWidget {
  const AsistenteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Asistente',
      debugShowCheckedModeBanner: false,
      theme: temaClaro(),
      darkTheme: temaOscuro(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
