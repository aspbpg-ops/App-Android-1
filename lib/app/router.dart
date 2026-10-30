import 'package:asistente_app/features/home/presentation/home_page.dart';
import 'package:asistente_app/features/onboarding/presentation/onboarding_controller.dart';
import 'package:asistente_app/features/onboarding/presentation/onboarding_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

abstract final class Rutas {
  static const onboarding = '/bienvenida';
  static const inicio = '/inicio';
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Rutas.onboarding,
    redirect: (context, state) {
      final completo = ref.read(onboardingControllerProvider).completo;
      final enOnboarding = state.matchedLocation == Rutas.onboarding;
      if (!completo && !enOnboarding) return Rutas.onboarding;
      if (completo && enOnboarding) return Rutas.inicio;
      return null;
    },
    routes: [
      GoRoute(
        path: Rutas.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: Rutas.inicio,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
  ref
    ..listen(
      onboardingControllerProvider.select((d) => d.completo),
      (_, _) => router.refresh(),
    )
    ..onDispose(router.dispose);
  return router;
});
