import 'package:flutter/material.dart';

/// Mensaje amable cuando una sección todavía no tiene nada.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    required this.icono,
    required this.titulo,
    required this.detalle,
    super.key,
  });

  final String icono;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icono, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(titulo, style: texto.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(detalle, style: texto.bodyLarge, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
