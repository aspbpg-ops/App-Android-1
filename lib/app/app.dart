import 'package:asistente_app/app/router.dart';
import 'package:asistente_app/app/theme.dart';
import 'package:asistente_app/features/avisos/data/notificador.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsistenteApp extends ConsumerWidget {
  const AsistenteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sincronizarAvisosProvider);
    return MaterialApp.router(
      title: 'Asistente',
      debugShowCheckedModeBanner: false,
      theme: temaClaro(),
      darkTheme: temaOscuro(),
      locale: const Locale('es', 'MX'),
      supportedLocales: const [Locale('es', 'MX')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
