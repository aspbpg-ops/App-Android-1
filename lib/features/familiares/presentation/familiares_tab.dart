import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/core/widgets/confirmar.dart';
import 'package:asistente_app/core/widgets/estado_vacio.dart';
import 'package:asistente_app/features/familiares/domain/familiar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _detalle(Familiar familiar, DateTime hoy) {
  final cumple = familiar.cumple;
  final falta = cumple == null
      ? ''
      : cuantoFalta(proximoCumple(cumple, hoy), hoy).toLowerCase();
  return [
    familiar.parentesco,
    if (cumple != null) '🎂 ${diaYMes(cumple)} ($falta)',
    if (familiar.telefono.isNotEmpty) '📞 ${familiar.telefono}',
  ].join('\n');
}

class FamiliaresTab extends ConsumerWidget {
  const FamiliaresTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familiares = ref.watch(datosProvider).familiares;
    final hoy = ref.watch(relojProvider)();
    if (familiares.isEmpty) {
      return const EstadoVacio(
        icono: '🎂',
        titulo: 'Tu gente importante',
        detalle:
            'Agrega a tu pareja, hijos, papás o a tu jefe con su cumpleaños '
            'y teléfono. Te aviso antes de cada cumpleaños.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        for (final familiar in familiares)
          Card(
            child: ListTile(
              key: ValueKey(familiar.id),
              leading: CircleAvatar(
                child: Text(familiar.nombre.characters.first.toUpperCase()),
              ),
              title: Text(familiar.nombre),
              subtitle: Text(_detalle(familiar, hoy)),
              isThreeLine:
                  familiar.cumple != null && familiar.telefono.isNotEmpty,
              trailing: IconButton(
                tooltip: 'Borrar',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final borrar = await confirmarBorrado(
                    context,
                    titulo: '¿Borrar a ${familiar.nombre}?',
                    detalle:
                        'También se borra el recordatorio de su '
                        'cumpleaños.',
                  );
                  if (borrar) {
                    ref
                        .read(datosProvider.notifier)
                        .borrarFamiliar(familiar.id);
                  }
                },
              ),
            ),
          ),
      ],
    );
  }
}
