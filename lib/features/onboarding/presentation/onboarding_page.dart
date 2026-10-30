import 'package:asistente_app/features/onboarding/presentation/onboarding_controller.dart';
import 'package:asistente_app/features/onboarding/presentation/pasos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asistente de bienvenida: una pregunta por pantalla.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _paginas = PageController();
  var _indice = 0;

  PasoOnboarding get _paso => PasoOnboarding.values[_indice];
  bool get _esUltimo => _indice == PasoOnboarding.values.length - 1;

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  Future<void> _irA(int indice) async {
    FocusScope.of(context).unfocus();
    setState(() => _indice = indice);
    await _paginas.animateToPage(
      indice,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final puedeAvanzar = controller.puedeAvanzar(_paso);
    final total = PasoOnboarding.values.length;

    return Scaffold(
      appBar: AppBar(
        leading: _indice == 0
            ? null
            : IconButton(
                tooltip: 'Atrás',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _irA(_indice - 1),
              ),
        title: Text('Paso ${_indice + 1} de $total'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_indice + 1) / total),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _paginas,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  PasoBienvenida(),
                  PasoNombre(),
                  PasoAvatar(),
                  PasoEtapa(),
                  PasoCompartir(),
                  PasoRespaldo(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                key: const Key('boton-continuar'),
                onPressed: !puedeAvanzar
                    ? null
                    : _esUltimo
                    ? controller.terminar
                    : () => _irA(_indice + 1),
                child: Text(
                  _indice == 0
                      ? 'Empezar'
                      : _esUltimo
                      ? 'Terminar'
                      : 'Continuar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
