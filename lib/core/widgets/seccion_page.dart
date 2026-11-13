import 'package:flutter/material.dart';

/// Pantalla de una sección de "Mi vida" con su botón de agregar.
class SeccionPage extends StatelessWidget {
  const SeccionPage({
    required this.titulo,
    required this.cuerpo,
    this.agregar,
    this.nueva,
    super.key,
  });

  final String titulo;
  final Widget cuerpo;
  final String? agregar;
  final Widget Function()? nueva;

  @override
  Widget build(BuildContext context) {
    final nueva = this.nueva;
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: SafeArea(child: cuerpo),
      floatingActionButton: nueva == null
          ? null
          : FloatingActionButton.extended(
              key: const Key('boton-agregar-seccion'),
              icon: const Icon(Icons.add),
              label: Text(agregar ?? 'Agregar'),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (context) => nueva())),
            ),
    );
  }
}
