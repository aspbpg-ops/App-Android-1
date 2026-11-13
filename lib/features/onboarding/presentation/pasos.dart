import 'package:asistente_app/features/onboarding/presentation/onboarding_controller.dart';
import 'package:asistente_app/features/perfil/domain/perfil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Marco común: título grande, explicación corta y el contenido del paso.
class _Paso extends StatelessWidget {
  const _Paso({
    required this.titulo,
    required this.explicacion,
    required this.child,
  });

  final String titulo;
  final String explicacion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(titulo, style: texto.headlineMedium),
          const SizedBox(height: 12),
          Text(explicacion, style: texto.bodyLarge),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }
}

class PasoBienvenida extends StatelessWidget {
  const PasoBienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Paso(
      titulo: 'Hola 👋',
      explicacion:
          'Te ayudo a recordar lo importante: el seguro del auto, las '
          'vacunas de tu mascota, el predial o el cumpleaños de alguien '
          'querido. Todo se guarda solo en este celular. Vamos a '
          'configurarlo en pocos pasos.',
      child: Text(
        '🗓️',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 96),
      ),
    );
  }
}

class PasoNombre extends ConsumerWidget {
  const PasoNombre({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Paso(
      titulo: '¿Cómo te llamas?',
      explicacion: 'Así te saludaremos cada día.',
      child: TextFormField(
        key: const Key('campo-nombre'),
        initialValue: ref.read(onboardingControllerProvider).nombre,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Tu nombre'),
        onChanged: ref
            .read(onboardingControllerProvider.notifier)
            .cambiarNombre,
      ),
    );
  }
}

class PasoAvatar extends ConsumerWidget {
  const PasoAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elegido = ref.watch(onboardingControllerProvider).avatar;
    final colores = Theme.of(context).colorScheme;
    return _Paso(
      titulo: 'Elige tu avatar',
      explicacion: 'Podrás cambiarlo cuando quieras.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          for (final avatar in avataresDisponibles)
            ChoiceChip(
              key: Key('avatar-$avatar'),
              label: Text(avatar, style: const TextStyle(fontSize: 36)),
              selected: avatar == elegido,
              selectedColor: colores.primaryContainer,
              showCheckmark: false,
              onSelected: (_) => ref
                  .read(onboardingControllerProvider.notifier)
                  .elegirAvatar(avatar),
            ),
        ],
      ),
    );
  }
}

class PasoEtapa extends ConsumerWidget {
  const PasoEtapa({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elegida = ref.watch(onboardingControllerProvider).etapa;
    return _Paso(
      titulo: '¿Cómo vives hoy?',
      explicacion: 'Con esto te sugerimos qué registrar primero.',
      child: RadioGroup<EtapaDeVida>(
        groupValue: elegida,
        onChanged: (etapa) {
          if (etapa != null) {
            ref.read(onboardingControllerProvider.notifier).elegirEtapa(etapa);
          }
        },
        child: Column(
          children: [
            for (final etapa in EtapaDeVida.values)
              Card(
                child: RadioListTile<EtapaDeVida>(
                  key: Key('etapa-${etapa.name}'),
                  value: etapa,
                  title: Text('${etapa.icono}  ${etapa.etiqueta}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
