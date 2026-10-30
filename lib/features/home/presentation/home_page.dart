import 'package:asistente_app/features/onboarding/presentation/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Inicio provisional: saluda y muestra las secciones del MVP que siguen.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const List<(IconData, String, String)> _secciones = [
    (Icons.folder_shared_outlined, 'Mis fichas', 'Auto, casa, mascota, hijos'),
    (Icons.family_restroom, 'Familiares', 'Cumpleaños y teléfonos'),
    (Icons.notifications_outlined, 'Recordatorios', 'Lo que viene esta semana'),
    (
      Icons.handshake_outlined,
      'Entorno compartido',
      'Responsabilidades y pagos',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(onboardingControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Text(perfil.avatar ?? '🙂', style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Hola, ${perfil.nombre.trim()}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          if (perfil.correoInvitado != null) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.mail_outline),
                title: const Text('Invitación pendiente'),
                subtitle: Text(perfil.correoInvitado!),
              ),
            ),
          ],
          const SizedBox(height: 24),
          for (final (icono, titulo, detalle) in _secciones)
            Card(
              child: ListTile(
                leading: Icon(icono),
                title: Text(titulo),
                subtitle: Text(detalle),
                trailing: const Text('Pronto'),
              ),
            ),
        ],
      ),
    );
  }
}
