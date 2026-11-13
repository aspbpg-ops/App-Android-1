import 'package:flutter/material.dart';

/// Pregunta antes de borrar algo; devuelve `true` si la persona acepta.
Future<bool> confirmarBorrado(
  BuildContext context, {
  required String titulo,
  required String detalle,
}) async {
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(detalle),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Borrar'),
        ),
      ],
    ),
  );
  return respuesta ?? false;
}
