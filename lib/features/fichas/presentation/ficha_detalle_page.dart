import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/widgets/confirmar.dart';
import 'package:asistente_app/features/recordatorios/presentation/nuevo_recordatorio_page.dart';
import 'package:asistente_app/features/recordatorios/presentation/recordatorio_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FichaDetallePage extends ConsumerWidget {
  const FichaDetallePage(this.fichaId, {super.key});

  final String fichaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(datosProvider);
    final ficha = datos.fichas.where((f) => f.id == fichaId).firstOrNull;
    // La ficha acaba de borrarse y la pantalla está por cerrarse.
    if (ficha == null) return const Scaffold();
    final pendientes = datos.pendientesDeFicha(fichaId);
    final texto = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(ficha.tipo.etiqueta),
        actions: [
          IconButton(
            tooltip: 'Borrar ficha',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final borrar = await confirmarBorrado(
                context,
                titulo: '¿Borrar "${ficha.nombre}"?',
                detalle: 'También se borran sus recordatorios.',
              );
              if (!borrar || !context.mounted) return;
              Navigator.pop(context);
              ref.read(datosProvider.notifier).borrarFicha(fichaId);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Recordatorio'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => NuevoRecordatorioPage(fichaId: fichaId),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Text(ficha.tipo.icono, style: const TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(ficha.nombre, style: texto.headlineSmall),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
              child: Text(
                pendientes.isEmpty
                    ? 'Sin recordatorios pendientes'
                    : 'Recordatorios (${pendientes.length})',
                style: texto.titleMedium,
              ),
            ),
            for (final r in pendientes)
              RecordatorioTile(r, mostrarOrigen: false, key: ValueKey(r.id)),
          ],
        ),
      ),
    );
  }
}
