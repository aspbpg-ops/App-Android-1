import 'package:asistente_app/app/theme.dart';
import 'package:asistente_app/features/asistente/presentation/asistente_sheet.dart';
import 'package:flutter/material.dart';

/// La barra "Recuérdame…" de abajo: tocar abre el asistente para escribir,
/// el micrófono lo abre escuchando.
class BarraAsistente extends StatelessWidget {
  const BarraAsistente({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Paleta.de(context);
    return Material(
      color: p.tarjeta,
      shape: StadiumBorder(side: BorderSide(color: p.separador)),
      child: InkWell(
        key: const Key('barra-asistente'),
        customBorder: const StadiumBorder(),
        onTap: () => abrirAsistente(context),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              const SizedBox(width: 18),
              Icon(Icons.add, color: p.acento),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Recuérdame…',
                  style: TextStyle(color: p.textoSecundario, fontSize: 16),
                ),
              ),
              IconButton(
                key: const Key('barra-microfono'),
                tooltip: 'Dictar',
                icon: Icon(Icons.mic_none, color: p.acento),
                onPressed: () => abrirAsistente(context, escucharAlAbrir: true),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
