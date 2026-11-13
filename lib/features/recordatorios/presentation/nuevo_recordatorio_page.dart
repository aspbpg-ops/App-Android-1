import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/core/widgets/campo_fecha.dart';
import 'package:asistente_app/features/recordatorios/domain/recordatorio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const opcionesRepeticion = [0, 1, 2, 3, 6, 12];

class NuevoRecordatorioPage extends ConsumerStatefulWidget {
  const NuevoRecordatorioPage({this.fichaId, super.key});

  /// Si viene de una ficha, el recordatorio queda ligado a ella.
  final String? fichaId;

  @override
  ConsumerState<NuevoRecordatorioPage> createState() =>
      _NuevoRecordatorioPageState();
}

class _NuevoRecordatorioPageState extends ConsumerState<NuevoRecordatorioPage> {
  var _titulo = '';
  DateTime? _fecha;
  var _cadaMeses = 0;

  bool get _listo => _titulo.trim().isNotEmpty && _fecha != null;

  void _guardar() {
    ref
        .read(datosProvider.notifier)
        .agregarRecordatorio(
          RecordatorioNuevo(
            titulo: _titulo,
            fecha: _fecha!,
            cadaMeses: _cadaMeses,
          ),
          fichaId: widget.fichaId,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final hoy = soloDia(ref.watch(relojProvider)());
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo recordatorio')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              key: const Key('campo-titulo'),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: '¿Qué no quieres olvidar?',
                hintText: 'Ej. Pagar la tarjeta',
              ),
              onChanged: (valor) => setState(() => _titulo = valor),
            ),
            const SizedBox(height: 20),
            CampoFecha(
              key: const Key('campo-fecha'),
              etiqueta: '¿Cuándo?',
              fecha: _fecha,
              primera: hoy,
              ultima: DateTime(hoy.year + 10, 12, 31),
              onCambio: (fecha) => setState(() => _fecha = fecha),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              initialValue: _cadaMeses,
              decoration: const InputDecoration(labelText: '¿Se repite?'),
              items: [
                for (final meses in opcionesRepeticion)
                  DropdownMenuItem(
                    value: meses,
                    child: Text(textoRepeticion(meses)),
                  ),
              ],
              onChanged: (valor) => setState(() => _cadaMeses = valor ?? 0),
            ),
            const SizedBox(height: 32),
            FilledButton(
              key: const Key('boton-guardar'),
              onPressed: _listo ? _guardar : null,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
