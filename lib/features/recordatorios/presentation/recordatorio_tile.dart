import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/features/recordatorios/domain/recordatorio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Un recordatorio pendiente: se marca como hecho con el círculo.
class RecordatorioTile extends ConsumerWidget {
  const RecordatorioTile(
    this.recordatorio, {
    this.mostrarOrigen = true,
    super.key,
  });

  final Recordatorio recordatorio;

  /// Muestra a qué ficha pertenece (se oculta dentro de la propia ficha).
  final bool mostrarOrigen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(datosProvider);
    final hoy = ref.watch(relojProvider)();
    final controller = ref.read(datosProvider.notifier);
    final colores = Theme.of(context).colorScheme;
    final atrasado = diasHasta(recordatorio.fecha, hoy) < 0;
    final ficha = datos.fichas
        .where((f) => f.id == recordatorio.fichaId)
        .firstOrNull;

    final detalle = [
      cuantoFalta(recordatorio.fecha, hoy),
      fechaCorta(recordatorio.fecha, hoy),
      if (mostrarOrigen && ficha != null) '${ficha.tipo.icono} ${ficha.nombre}',
    ].join(' · ');

    return Card(
      child: ListTile(
        leading: IconButton(
          tooltip: 'Marcar como hecho',
          icon: const Icon(Icons.radio_button_unchecked),
          onPressed: () {
            controller.cumplir(recordatorio.id);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    recordatorio.seRepite
                        ? 'Hecho. Te lo recordaré de nuevo el '
                              '${fechaLarga(recordatorio.cumplido().fecha)}.'
                        : 'Hecho.',
                  ),
                ),
              );
          },
        ),
        title: Text(recordatorio.titulo),
        subtitle: Text(
          detalle,
          style: atrasado ? TextStyle(color: colores.error) : null,
        ),
        trailing: PopupMenuButton<void>(
          tooltip: 'Más opciones',
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => controller.borrarRecordatorio(recordatorio.id),
              child: const Text('Borrar'),
            ),
          ],
        ),
      ),
    );
  }
}
