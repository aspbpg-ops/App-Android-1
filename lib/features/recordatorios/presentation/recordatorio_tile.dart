import 'package:asistente_app/app/theme.dart';
import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/features/recordatorios/domain/recordatorio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Marca como hecho y ofrece deshacerlo.
void cumplirConAviso(
  BuildContext context,
  WidgetRef ref,
  Recordatorio recordatorio,
) {
  ref.read(datosProvider.notifier).cumplir(recordatorio.id);
  final siguiente = recordatorio.seRepite
      ? ' Vuelve el ${fechaLarga(recordatorio.cumplido().fecha)}.'
      : '';
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Hecho: ${recordatorio.titulo}.$siguiente'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () =>
              ref.read(datosProvider.notifier).restaurar(recordatorio),
        ),
      ),
    );
}

/// Fila de agenda: casilla circular, título y, a la derecha, la hora.
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
    final p = Paleta.de(context);
    final texto = Theme.of(context).textTheme;
    final dias = diasHasta(recordatorio.fecha, hoy);
    final ficha = datos.fichas
        .where((f) => f.id == recordatorio.fichaId)
        .firstOrNull;

    final detalle = [
      if (dias != 0) cuantoFalta(recordatorio.fecha, hoy),
      if (dias.abs() > 1) fechaCorta(recordatorio.fecha, hoy),
      if (mostrarOrigen && ficha != null) '${ficha.tipo.icono} ${ficha.nombre}',
      if (recordatorio.seRepite) textoRepeticion(recordatorio.cadaMeses),
    ].join(' · ');
    final hora = recordatorio.hora;

    return Column(
      children: [
        InkWell(
          onLongPress: () => _opciones(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Marcar como hecho',
                  icon: Icon(
                    Icons.circle_outlined,
                    color: p.textoSecundario,
                    size: 26,
                  ),
                  onPressed: () => cumplirConAviso(context, ref, recordatorio),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recordatorio.titulo, style: texto.bodyLarge),
                      if (detalle.isNotEmpty)
                        Text(
                          detalle,
                          style: texto.bodySmall?.copyWith(
                            color: dias < 0
                                ? Colors.red.shade400
                                : p.textoSecundario,
                          ),
                        ),
                    ],
                  ),
                ),
                if (hora != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 4),
                    child: Text(
                      textoHora(hora),
                      style: texto.bodyMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Divider(indent: 52),
      ],
    );
  }

  Future<void> _opciones(BuildContext context, WidgetRef ref) async {
    final borrar = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                recordatorio.titulo,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Borrar recordatorio'),
              onTap: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );
    if (borrar ?? false) {
      ref.read(datosProvider.notifier).borrarRecordatorio(recordatorio.id);
    }
  }
}
