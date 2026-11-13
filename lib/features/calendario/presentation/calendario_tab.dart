import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/features/recordatorios/presentation/nuevo_recordatorio_page.dart';
import 'package:asistente_app/features/recordatorios/presentation/recordatorio_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _diasSemana = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

/// Mes en cuadrícula: los días con pendientes llevan un punto.
class CalendarioTab extends ConsumerStatefulWidget {
  const CalendarioTab({super.key});

  @override
  ConsumerState<CalendarioTab> createState() => _CalendarioTabState();
}

class _CalendarioTabState extends ConsumerState<CalendarioTab> {
  late DateTime _mes;
  late DateTime _dia;

  @override
  void initState() {
    super.initState();
    _dia = soloDia(ref.read(relojProvider)());
    _mes = DateTime(_dia.year, _dia.month);
  }

  void _moverMes(int delta) =>
      setState(() => _mes = DateTime(_mes.year, _mes.month + delta));

  @override
  Widget build(BuildContext context) {
    final datos = ref.watch(datosProvider);
    final hoy = soloDia(ref.watch(relojProvider)());
    final texto = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;

    // Cuántos pendientes hay por día del mes visible.
    final conteo = <int, int>{};
    for (final r in datos.pendientes) {
      if (r.fecha.year == _mes.year && r.fecha.month == _mes.month) {
        conteo.update(r.fecha.day, (n) => n + 1, ifAbsent: () => 1);
      }
    }
    final huecos = DateTime(_mes.year, _mes.month).weekday - 1;
    final diasDelMes = DateTime(_mes.year, _mes.month + 1, 0).day;
    final delDia = datos.pendientesDelDia(_dia);
    final titulo = fechaLarga(_mes).split(' de ').skip(1).join(' de ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Mes anterior',
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _moverMes(-1),
            ),
            Expanded(
              child: Text(
                titulo[0].toUpperCase() + titulo.substring(1),
                textAlign: TextAlign.center,
                style: texto.titleLarge,
              ),
            ),
            IconButton(
              tooltip: 'Mes siguiente',
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _moverMes(1),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final d in _diasSemana)
              Center(child: Text(d, style: texto.labelLarge)),
            for (var i = 0; i < huecos; i++) const SizedBox.shrink(),
            for (var d = 1; d <= diasDelMes; d++)
              _Dia(
                dia: d,
                elegido: _dia == DateTime(_mes.year, _mes.month, d),
                esHoy: hoy == DateTime(_mes.year, _mes.month, d),
                pendientes: conteo[d] ?? 0,
                onTap: () =>
                    setState(() => _dia = DateTime(_mes.year, _mes.month, d)),
              ),
          ],
        ),
        const Divider(height: 32),
        Row(
          children: [
            Expanded(
              child: Text(
                '${cuantoFalta(_dia, hoy)} · ${fechaLarga(_dia)}',
                style: texto.titleMedium,
              ),
            ),
            if (!_dia.isBefore(hoy))
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Agregar'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        NuevoRecordatorioPage(fechaInicial: _dia),
                  ),
                ),
              ),
          ],
        ),
        if (delDia.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Nada para este día.',
              style: texto.bodyLarge?.copyWith(color: colores.outline),
            ),
          ),
        for (final r in delDia) RecordatorioTile(r, key: ValueKey(r.id)),
      ],
    );
  }
}

class _Dia extends StatelessWidget {
  const _Dia({
    required this.dia,
    required this.elegido,
    required this.esHoy,
    required this.pendientes,
    required this.onTap,
  });

  final int dia;
  final bool elegido;
  final bool esHoy;
  final int pendientes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return InkWell(
      key: Key('dia-$dia'),
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: elegido ? colores.primary : null,
          border: esHoy && !elegido
              ? Border.all(color: colores.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dia',
              style: TextStyle(
                color: elegido ? colores.onPrimary : null,
                fontWeight: esHoy ? FontWeight.bold : null,
              ),
            ),
            if (pendientes > 0)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: elegido ? colores.onPrimary : colores.tertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
