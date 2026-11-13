import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/widgets/confirmar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PerfilTab extends ConsumerWidget {
  const PerfilTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(datosProvider);
    final perfil = datos.perfil;
    if (perfil == null) return const SizedBox.shrink();
    final texto = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Text(perfil.avatar, style: const TextStyle(fontSize: 80)),
        ),
        const SizedBox(height: 8),
        Text(
          perfil.nombre,
          style: texto.headlineSmall,
          textAlign: TextAlign.center,
        ),
        Text(
          '${perfil.etapa.icono} ${perfil.etapa.etiqueta}',
          style: texto.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('Fichas'),
                trailing: Text('${datos.fichas.length}'),
              ),
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Familiares'),
                trailing: Text('${datos.familiares.length}'),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Recordatorios pendientes'),
                trailing: Text('${datos.pendientes.length}'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Card(
          child: ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Tus datos están solo en este celular'),
            subtitle: Text(
              'No se envían a internet. Si desinstalas la app o cambias de '
              'celular, se pierden.',
            ),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          key: const Key('boton-borrar-todo'),
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Borrar todos mis datos'),
          onPressed: () async {
            final borrar = await confirmarBorrado(
              context,
              titulo: '¿Borrar todo?',
              detalle:
                  'Se borran tu perfil, fichas, familiares y recordatorios. '
                  'No se puede deshacer.',
            );
            if (borrar) ref.read(datosProvider.notifier).borrarTodo();
          },
        ),
      ],
    );
  }
}
