import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/core/widgets/estado_vacio.dart';
import 'package:asistente_app/features/notas/domain/nota.dart';
import 'package:asistente_app/features/notas/presentation/nota_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notas del día a día, filtrables por categoría.
class NotasTab extends ConsumerStatefulWidget {
  const NotasTab({super.key});

  @override
  ConsumerState<NotasTab> createState() => _NotasTabState();
}

class _NotasTabState extends ConsumerState<NotasTab> {
  String? _categoria;

  @override
  Widget build(BuildContext context) {
    final datos = ref.watch(datosProvider);
    final hoy = ref.watch(relojProvider)();
    if (datos.notas.isEmpty) {
      return const EstadoVacio(
        icono: '📝',
        titulo: 'Sin notas',
        detalle:
            'Apunta lo que se te ocurra durante el día y clasifícalo. Las '
            'que dejes pendientes te las recuerdo al final del día.',
      );
    }
    final usadas = {for (final n in datos.notas) n.categoria};
    final visibles = datos.notas
        .where((n) => _categoria == null || n.categoria == _categoria)
        .toList();
    final pendientes = visibles.where((n) => n.pendiente).toList();
    final hechas = visibles.where((n) => !n.pendiente).toList();
    final texto = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final c in [
                null,
                ...datos.categorias.where(usadas.contains),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    key: Key('filtro-${c ?? 'todas'}'),
                    label: Text(c ?? 'Todas'),
                    selected: _categoria == c,
                    onSelected: (_) => setState(() => _categoria = c),
                  ),
                ),
            ],
          ),
        ),
        if (pendientes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
            child: Text(
              'Pendientes (${pendientes.length})',
              style: texto.titleMedium,
            ),
          ),
        for (final n in pendientes) _NotaTile(n, hoy: hoy, key: ValueKey(n.id)),
        if (hechas.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
            child: Text(
              'Terminadas (${hechas.length})',
              style: texto.titleMedium,
            ),
          ),
        for (final n in hechas) _NotaTile(n, hoy: hoy, key: ValueKey(n.id)),
      ],
    );
  }
}

class _NotaTile extends ConsumerWidget {
  const _NotaTile(this.nota, {required this.hoy, super.key});

  final Nota nota;
  final DateTime hoy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colores = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: !nota.pendiente,
          onChanged: (_) =>
              ref.read(datosProvider.notifier).alternarNotaPendiente(nota.id),
        ),
        title: Text(
          nota.texto,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: nota.pendiente
              ? null
              : TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: colores.outline,
                ),
        ),
        subtitle: Text('${nota.categoria} · ${cuantoFalta(nota.creada, hoy)}'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (context) => NotaPage(nota: nota)),
        ),
      ),
    );
  }
}
