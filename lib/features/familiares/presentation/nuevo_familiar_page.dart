import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/core/widgets/campo_fecha.dart';
import 'package:asistente_app/features/familiares/domain/familiar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NuevoFamiliarPage extends ConsumerStatefulWidget {
  const NuevoFamiliarPage({super.key});

  @override
  ConsumerState<NuevoFamiliarPage> createState() => _NuevoFamiliarPageState();
}

class _NuevoFamiliarPageState extends ConsumerState<NuevoFamiliarPage> {
  var _nombre = '';
  String _parentesco = parentescos.first;
  DateTime? _cumple;
  var _telefono = '';

  void _guardar() {
    ref
        .read(datosProvider.notifier)
        .agregarFamiliar(
          nombre: _nombre,
          parentesco: _parentesco,
          cumple: _cumple,
          telefono: _telefono,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final hoy = soloDia(ref.watch(relojProvider)());
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo familiar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              key: const Key('campo-nombre-familiar'),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre'),
              onChanged: (valor) => setState(() => _nombre = valor),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _parentesco,
              decoration: const InputDecoration(labelText: '¿Quién es?'),
              items: [
                for (final p in parentescos)
                  DropdownMenuItem(value: p, child: Text(p)),
              ],
              onChanged: (valor) =>
                  setState(() => _parentesco = valor ?? _parentesco),
            ),
            const SizedBox(height: 20),
            CampoFecha(
              key: const Key('campo-cumple'),
              etiqueta: 'Fecha de nacimiento (opcional)',
              fecha: _cumple,
              primera: DateTime(1920),
              ultima: hoy,
              onCambio: (fecha) => setState(() => _cumple = fecha),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono (opcional)',
              ),
              onChanged: (valor) => _telefono = valor,
            ),
            const SizedBox(height: 32),
            FilledButton(
              key: const Key('boton-guardar-familiar'),
              onPressed: _nombre.trim().isEmpty ? null : _guardar,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
