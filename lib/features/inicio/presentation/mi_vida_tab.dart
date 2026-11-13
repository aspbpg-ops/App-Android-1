import 'package:asistente_app/app/theme.dart';
import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/features/fichas/presentation/ficha_detalle_page.dart';
import 'package:asistente_app/features/inicio/presentation/accesos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tus espacios personales y lo que tienes registrado.
class MiVidaTab extends ConsumerWidget {
  const MiVidaTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(datosProvider);
    final hoy = ref.watch(relojProvider)();
    final texto = Theme.of(context).textTheme;
    final p = Paleta.de(context);

    String resumen(Acceso a) => switch (a) {
      Acceso.familia => '${datos.familiares.length} personas',
      Acceso.fichas => '${datos.fichas.length} registradas',
      Acceso.notas =>
        '${datos.notas.where((n) => n.pendiente).length} pendientes',
      Acceso.perfil => 'Tu información',
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text('Mi vida', style: texto.displaySmall),
        const SizedBox(height: 20),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 156,
          ),
          children: [
            for (final a in Acceso.values)
              Material(
                color: p.tarjeta,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: p.separador.withValues(alpha: 0.6)),
                ),
                child: InkWell(
                  key: Key('mi-vida-${a.name}'),
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => a.abrir(context),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: p.detalle,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(a.icono, color: p.texto, size: 22),
                        ),
                        const Spacer(),
                        Text(
                          a.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: texto.titleMedium,
                        ),
                        Text(
                          resumen(a),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: texto.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (datos.fichas.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text('Tus fichas', style: texto.titleMedium),
          const SizedBox(height: 8),
          for (final ficha in datos.fichas)
            Card(
              child: Builder(
                builder: (context) {
                  final siguiente = datos
                      .pendientesDeFicha(ficha.id)
                      .firstOrNull;
                  return ListTile(
                    leading: Text(
                      ficha.tipo.icono,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(ficha.nombre),
                    subtitle: Text(
                      siguiente == null
                          ? 'Sin pendientes'
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
      ],
    );
  }
}
