import 'package:asistente_app/core/fechas.dart';
import 'package:flutter/material.dart';

/// Campo que muestra una fecha y abre el calendario al tocarlo.
class CampoFecha extends StatelessWidget {
  const CampoFecha({
    required this.etiqueta,
    required this.fecha,
    required this.onCambio,
    required this.primera,
    required this.ultima,
    this.vacio = 'Toca para elegir',
    super.key,
  });

  final String etiqueta;
  final DateTime? fecha;
  final ValueChanged<DateTime> onCambio;
  final DateTime primera;
  final DateTime ultima;
  final String vacio;

  Future<void> _elegir(BuildContext context) async {
    final inicial = fecha ?? DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: inicial.isAfter(ultima)
          ? ultima
          : inicial.isBefore(primera)
          ? primera
          : inicial,
      firstDate: primera,
      lastDate: ultima,
    );
    if (elegida != null) onCambio(elegida);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _elegir(context),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(fecha == null ? vacio : fechaLarga(fecha!)),
      ),
    );
  }
}
