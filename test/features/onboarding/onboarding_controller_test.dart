import 'package:asistente_app/features/onboarding/domain/perfil_inicial.dart';
import 'package:asistente_app/features/onboarding/presentation/onboarding_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  OnboardingController controller() =>
      container.read(onboardingControllerProvider.notifier);
  PerfilInicial estado() => container.read(onboardingControllerProvider);

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('empieza vacío y sin terminar', () {
    expect(estado().nombre, isEmpty);
    expect(estado().completo, isFalse);
  });

  test('el nombre necesita al menos dos letras', () {
    controller().cambiarNombre(' A ');
    expect(controller().puedeAvanzar(PasoOnboarding.nombre), isFalse);
    controller().cambiarNombre('Ana');
    expect(controller().puedeAvanzar(PasoOnboarding.nombre), isTrue);
  });

  test('invitar es opcional pero el correo debe ser válido', () {
    expect(controller().puedeAvanzar(PasoOnboarding.compartir), isTrue);
    controller().invitarA('ana@');
    expect(controller().puedeAvanzar(PasoOnboarding.compartir), isFalse);
    controller().invitarA(' ana@correo.mx ');
    expect(estado().correoInvitado, 'ana@correo.mx');
    controller().invitarA('');
    expect(estado().correoInvitado, isNull);
  });

  test('no termina sin aceptar la clave de respaldo', () {
    controller()
      ..cambiarNombre('Ana')
      ..elegirAvatar(avataresDisponibles.first)
      ..elegirEtapa(EtapaDeVida.pareja)
      ..terminar();
    expect(estado().completo, isFalse);

    controller()
      ..confirmarRespaldo(entendido: true)
      ..terminar();
    expect(estado().completo, isTrue);
  });
}
