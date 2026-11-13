import 'package:asistente_app/app/theme.dart';
import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/features/familiares/domain/familiar.dart';
import 'package:asistente_app/features/fichas/domain/ficha.dart';
import 'package:asistente_app/features/inicio/presentation/accesos.dart';
import 'package:asistente_app/features/recordatorios/domain/recordatorio.dart';
import 'package:asistente_app/features/recordatorios/presentation/recordatorio_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _saludo(DateTime ahora) => switch (ahora.hour) {
  < 12 => 'Buenos días',
  < 19 => 'Buenas tardes',
  _ => 'Buenas noches',
};

/// Tu día: el próximo pendiente destacado, accesos y la agenda.
class HoyTab extends ConsumerWidget {
  const HoyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(datosProvider);
    final ahora = ref.watch(relojProvider)();
    final p = Paleta.de(context);
    final texto = Theme.of(context).textTheme;
    final pendientes = datos.pendientes;
    final proximo = pendientes.firstOrNull;

    List<Recordatorio> entre(int desde, int hasta) =>
        pendientes.skip(1).where((r) {
          final dias = diasHasta(r.fecha, ahora);
          return dias >= desde && dias <= hasta;
        }).toList();

    final grupos = [
      ('Atrasados', entre(-100000, -1)),
      ('Después, sin prisa', entre(0, 7)),
      ('Este mes', entre(8, 30)),
      ('Más adelante', entre(31, 100000)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          '${_saludo(ahora)}, ${datos.perfil?.nombre ?? ''}',
          style: texto.bodyLarge?.copyWith(color: p.textoSecundario),
        ),
        const SizedBox(height: 4),
        Text(p.lema, style: texto.displaySmall),
        const SizedBox(height: 24),
        if (proximo == null)
          const _Destacado(
            icono: Icons.spa_outlined,
            titulo: 'Todo al día.',
            detalle: 'Disfruta tu tiempo.',
          )
        else
          _Destacado(
            icono: _iconoDe(proximo, datos.fichas),
            etiqueta: 'Tu próximo recordatorio',
            titulo: proximo.titulo,
            detalle: [
              cuantoFalta(proximo.fecha, ahora),
              if (proximo.hora != null) textoHora(proximo.hora!),
              _origen(proximo, datos.fichas, datos.familiares),
            ].whereType<String>().join(' · '),
            atrasado: diasHasta(proximo.fecha, ahora) < 0,
            alCumplir: () => cumplirConAviso(context, ref, proximo),
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            for (final acceso in Acceso.values)
              Expanded(child: _AccesoRedondo(acceso: acceso)),
          ],
        ),
        for (final (titulo, lista) in grupos)
          if (lista.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 4),
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

IconData _iconoDe(Recordatorio r, List<Ficha> fichas) {
  if (r.familiarId != null) return Icons.cake_outlined;
  final tipo = fichas.where((f) => f.id == r.fichaId).firstOrNull?.tipo;
  return switch (tipo) {
    TipoFicha.auto => Icons.directions_car_outlined,
    TipoFicha.casa => Icons.home_outlined,
    TipoFicha.mascota => Icons.pets_outlined,
    TipoFicha.renta => Icons.apartment_outlined,
    _ => Icons.notifications_none,
  };
}

String? _origen(Recordatorio r, List<Ficha> fichas, List<Familiar> familia) {
  if (r.familiarId != null) return 'Familia';
  return fichas.where((f) => f.id == r.fichaId).firstOrNull?.nombre;
}

class _Destacado extends StatelessWidget {
  const _Destacado({
    required this.icono,
    required this.titulo,
    required this.detalle,
    this.etiqueta,
    this.atrasado = false,
    this.alCumplir,
  });

  final IconData icono;
  final String? etiqueta;
  final String titulo;
  final String detalle;
  final bool atrasado;
  final VoidCallback? alCumplir;

  @override
  Widget build(BuildContext context) {
    final p = Paleta.de(context);
    final texto = Theme.of(context).textTheme;
    return Container(
      key: const Key('destacado'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: p.superficie,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: p.detalle,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icono, color: p.texto),
              ),
              const Spacer(),
              if (alCumplir != null)
                IconButton(
                  tooltip: 'Marcar como hecho',
                  icon: Icon(Icons.check_circle_outline, color: p.acento),
                  iconSize: 30,
                  onPressed: alCumplir,
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (etiqueta != null) Text(etiqueta!, style: texto.bodyMedium),
          Text(titulo, style: texto.headlineSmall),
          const SizedBox(height: 4),
          Text(
            detalle,
            style: texto.bodyMedium?.copyWith(
              color: atrasado ? Colors.red.shade400 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccesoRedondo extends StatelessWidget {
  const _AccesoRedondo({required this.acceso});

  final Acceso acceso;

  @override
  Widget build(BuildContext context) {
    final p = Paleta.de(context);
    return InkWell(
      key: Key('acceso-${acceso.name}'),
      borderRadius: BorderRadius.circular(16),
      onTap: () => acceso.abrir(context),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: p.detalle,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(acceso.icono, color: p.texto),
            ),
            const SizedBox(height: 8),
            Text(
              acceso.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
