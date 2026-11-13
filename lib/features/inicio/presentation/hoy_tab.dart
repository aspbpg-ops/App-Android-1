import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/core/widgets/estado_vacio.dart';
import 'package:asistente_app/features/recordatorios/domain/recordatorio.dart';
import 'package:asistente_app/features/recordatorios/presentation/recordatorio_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lo que viene: recordatorios pendientes agrupados por cercanía.
class HoyTab extends ConsumerWidget {
  const HoyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(datosProvider);
    final hoy = ref.watch(relojProvider)();
    final pendientes = datos.pendientes;
    final perfil = datos.perfil;
    final texto = Theme.of(context).textTheme;

    List<Recordatorio> entre(int desde, int hasta) => pendientes.where((r) {
      final dias = diasHasta(r.fecha, hoy);
      return dias >= desde && dias <= hasta;
    }).toList();

    final grupos = [
      ('Atrasados', entre(-100000, -1)),
      ('Esta semana', entre(0, 7)),
      ('Este mes', entre(8, 30)),
      ('Más adelante', entre(31, 100000)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (perfil != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Row(
              children: [
                Text(perfil.avatar, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, ${perfil.nombre}',
                        style: texto.headlineSmall,
                      ),
                      Text(fechaLarga(hoy), style: texto.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (pendientes.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 48),
            child: EstadoVacio(
              icono: '🗓️',
              titulo: 'Nada pendiente',
              detalle:
                  'Registra tu auto, tu casa o tu mascota en "Fichas" y te '
                  'propongo los recordatorios. También puedes agregar uno '
                  'aquí abajo.',
            ),
          ),
        for (final (titulo, lista) in grupos)
          if (lista.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
              child: Text(
                '$titulo (${lista.length})',
                style: texto.titleMedium,
              ),
            ),
            for (final r in lista) RecordatorioTile(r, key: ValueKey(r.id)),
          ],
      ],
    );
  }
}
