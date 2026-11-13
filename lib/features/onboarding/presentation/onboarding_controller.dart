import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/features/perfil/domain/perfil.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pasos del asistente, uno por pantalla.
enum PasoOnboarding { bienvenida, nombre, avatar, etapa }

/// Lo que la persona va contestando antes de crear su perfil.
@immutable
class BorradorPerfil {
  const BorradorPerfil({this.nombre = '', this.avatar, this.etapa});

  final String nombre;
  final String? avatar;
  final EtapaDeVida? etapa;

  bool get nombreValido => nombre.trim().length >= 2;

  BorradorPerfil copyWith({
    String? nombre,
    String? avatar,
    EtapaDeVida? etapa,
  }) => BorradorPerfil(
    nombre: nombre ?? this.nombre,
    avatar: avatar ?? this.avatar,
    etapa: etapa ?? this.etapa,
  );
}

class OnboardingController extends Notifier<BorradorPerfil> {
  @override
  BorradorPerfil build() => const BorradorPerfil();

  void cambiarNombre(String nombre) => state = state.copyWith(nombre: nombre);

  void elegirAvatar(String avatar) => state = state.copyWith(avatar: avatar);

  void elegirEtapa(EtapaDeVida etapa) => state = state.copyWith(etapa: etapa);

  /// Indica si la persona ya puede avanzar desde [paso].
  bool puedeAvanzar(PasoOnboarding paso) => switch (paso) {
    PasoOnboarding.bienvenida => true,
    PasoOnboarding.nombre => state.nombreValido,
    PasoOnboarding.avatar => state.avatar != null,
    PasoOnboarding.etapa => state.etapa != null,
  };

  /// Crea el perfil; a partir de ahí la app abre en el inicio.
  void terminar() {
    if (!PasoOnboarding.values.every(puedeAvanzar)) return;
    ref
        .read(datosProvider.notifier)
        .guardarPerfil(
          Perfil(
            nombre: state.nombre.trim(),
            avatar: state.avatar!,
            etapa: state.etapa!,
          ),
        );
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, BorradorPerfil>(
      OnboardingController.new,
    );
