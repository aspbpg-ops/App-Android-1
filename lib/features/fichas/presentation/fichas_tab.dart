import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/core/widgets/estado_vacio.dart';
import 'package:asistente_app/features/fichas/domain/ficha.dart';
import 'package:asistente_app/features/fichas/presentation/ficha_detalle_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FichasTab extends ConsumerWidget {
  const FichasTab({this.tipos, super.key});

  /// Solo muestra estos tipos; todas si es `null`.
  final Set<TipoFicha>? tipos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(datosProvider);
    final hoy = ref.watch(relojProvider)();
    final fichas = datos.fichas
        .where((f) => tipos == null || tipos!.contains(f.tipo))
        .toList();
    if (fichas.isEmpty) {
      return const EstadoVacio(
        icono: '🗂️',
        titulo: 'Aún no tienes fichas',
        detalle:
            'Una ficha es algo importante para ti: tu auto, tu casa, tu '
            'mascota o un departamento en renta. Al crearla te propongo '
            'qué recordar.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        for (final ficha in fichas)
          Card(
            child: Builder(
              builder: (context) {
                final pendientes = datos.pendientesDeFicha(ficha.id);
                final siguiente = pendientes.firstOrNull;
                return ListTile(
                  key: ValueKey(ficha.id),
                  leading: Text(
                    ficha.tipo.icono,
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(ficha.nombre),
                  subtitle: Text(
                    siguiente == null
                        ? '${ficha.tipo.etiqueta} · Sin pendientes'
                        : '${siguiente.titulo} · '
                              '${cuantoFalta(siguiente.fecha, hoy)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => FichaDetallePage(ficha.id),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
