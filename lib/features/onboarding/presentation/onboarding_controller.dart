import 'package:asistente_app/features/onboarding/domain/perfil_inicial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pasos del asistente, uno por pantalla.
enum PasoOnboarding { bienvenida, nombre, avatar, etapa, compartir, respaldo }

class OnboardingController extends Notifier<PerfilInicial> {
  @override
  PerfilInicial build() => const PerfilInicial();

  void cambiarNombre(String nombre) => state = state.copyWith(nombre: nombre);

  void elegirAvatar(String avatar) => state = state.copyWith(avatar: avatar);

  void elegirEtapa(EtapaDeVida etapa) => state = state.copyWith(etapa: etapa);

  void invitarA(String? correo) {
    final limpio = correo?.trim();
    state = state.copyWith(
      correoInvitado: () => (limpio == null || limpio.isEmpty) ? null : limpio,
    );
  }

  void confirmarRespaldo({required bool entendido}) =>
      state = state.copyWith(respaldoEntendido: entendido);

  /// Indica si la persona ya puede avanzar desde [paso].
  bool puedeAvanzar(PasoOnboarding paso) => switch (paso) {
    PasoOnboarding.bienvenida => true,
    PasoOnboarding.nombre => state.nombreValido,
    PasoOnboarding.avatar => state.avatar != null,
    PasoOnboarding.etapa => state.etapa != null,
    PasoOnboarding.compartir =>
      state.correoInvitado == null || esCorreoValido(state.correoInvitado!),
    PasoOnboarding.respaldo => state.respaldoEntendido,
  };

  void terminar() {
    if (PasoOnboarding.values.every(puedeAvanzar)) {
      state = state.copyWith(completo: true);
    }
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, PerfilInicial>(
      OnboardingController.new,
    );
