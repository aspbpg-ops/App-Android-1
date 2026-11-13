import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/features/inicio/presentation/inicio_page.dart';
import 'package:asistente_app/features/onboarding/presentation/onboarding_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

abstract final class Rutas {
  static const onboarding = '/bienvenida';
  static const inicio = '/inicio';
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Rutas.inicio,
    redirect: (context, state) {
      final conPerfil = ref.read(datosProvider).perfil != null;
      final enOnboarding = state.matchedLocation == Rutas.onboarding;
      if (!conPerfil && !enOnboarding) return Rutas.onboarding;
      if (conPerfil && enOnboarding) return Rutas.inicio;
      return null;
    },
    routes: [
      GoRoute(
        path: Rutas.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: Rutas.inicio,
        builder: (context, state) => const InicioPage(),
      ),
    ],
  );
  ref
    ..listen(
      datosProvider.select((d) => d.perfil != null),
      (_, _) => router.refresh(),
    )
    ..onDispose(router.dispose);
  return router;
});
