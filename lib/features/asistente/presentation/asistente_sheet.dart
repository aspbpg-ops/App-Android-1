import 'dart:async';

import 'package:asistente_app/app/theme.dart';
import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/features/asistente/domain/dictado.dart';
import 'package:asistente_app/features/asistente/domain/interprete.dart';
import 'package:asistente_app/features/asistente/domain/orden.dart';
import 'package:asistente_app/features/fichas/presentation/nueva_ficha_page.dart';
import 'package:asistente_app/features/notas/presentation/nota_page.dart';
import 'package:asistente_app/features/recordatorios/domain/recordatorio.dart';
import 'package:asistente_app/features/recordatorios/presentation/nuevo_recordatorio_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abre el asistente; al terminar lleva a la pantalla que corresponda.
Future<void> abrirAsistente(
  BuildContext context, {
  bool escucharAlAbrir = false,
}) async {
  final orden = await showModalBottomSheet<Orden>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _AsistenteSheet(escucharAlAbrir: escucharAlAbrir),
  );
  if (orden == null || !context.mounted) return;
  final pagina = switch (orden) {
    CrearFicha(:final tipo, :final nombre) => NuevaFichaPage(
      tipoInicial: tipo,
      nombreInicial: nombre,
    ),
    CrearRecordatorio(:final titulo, :final fecha, :final hora) =>
      NuevoRecordatorioPage(
        tituloInicial: titulo,
        fechaInicial: fecha,
        horaInicial: hora,
      ),
    CrearNota(:final texto, :final categoria) => NotaPage(
      textoInicial: texto,
      categoriaInicial: categoria,
    ),
  };
  await Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (context) => pagina));
}

/// Explica en palabras lo que la app entendió.
String describir(Orden orden, DateTime hoy) => switch (orden) {
  CrearFicha(:final tipo, :final nombre) =>
    'Nueva ficha: ${tipo.icono} ${tipo.etiqueta}'
        '${nombre.isEmpty ? '' : ' "$nombre"'}',
  CrearRecordatorio(:final titulo, :final fecha, :final hora) =>
    'Recordatorio: $titulo'
        '${fecha == null ? '' : ' · ${cuantoFalta(fecha, hoy)}'}'
        '${hora == null ? '' : ' a las ${textoHora(hora)}'}',
  CrearNota(:final categoria) => 'Nota en $categoria',
};

class _AsistenteSheet extends ConsumerStatefulWidget {
  const _AsistenteSheet({required this.escucharAlAbrir});

  final bool escucharAlAbrir;

  @override
  ConsumerState<_AsistenteSheet> createState() => _AsistenteSheetState();
}

class _AsistenteSheetState extends ConsumerState<_AsistenteSheet> {
  final _texto = TextEditingController();
  var _escuchando = false;
  String? _aviso;

  @override
  void initState() {
    super.initState();
    if (widget.escucharAlAbrir) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _microfono());
    }
  }

  @override
  void dispose() {
    if (_escuchando) unawaited(ref.read(dictadoProvider).detener());
    _texto.dispose();
    super.dispose();
  }

  Future<void> _microfono() async {
    final dictado = ref.read(dictadoProvider);
    if (_escuchando) {
      await dictado.detener();
      setState(() => _escuchando = false);
      return;
    }
    if (!await dictado.preparar()) {
      setState(
        () => _aviso =
            'No pude usar el micrófono. Revisa el permiso en Ajustes o '
            'escríbelo aquí.',
      );
      return;
    }
    setState(() {
      _escuchando = true;
      _aviso = null;
    });
    await dictado.escuchar((texto, {required alFinal}) {
      if (!mounted) return;
      setState(() {
        _texto.text = texto;
        if (alFinal) _escuchando = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Paleta.de(context);
    final texto = Theme.of(context).textTheme;
    final hoy = ref.watch(relojProvider)();
    final frase = _texto.text.trim();
    final orden = frase.isEmpty ? null : interpretar(frase, hoy);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _escuchando ? 'Te escucho…' : '¿Qué quieres recordar?',
            style: texto.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Ej. "Compré un auto", "Recuérdame mañana a las 10 llamar a '
            'mamá" o "El inquilino reportó una fuga".',
            style: texto.bodyMedium,
          ),
          const SizedBox(height: 20),
          TextField(
            key: const Key('campo-asistente'),
            controller: _texto,
            autofocus: !widget.escucharAlAbrir,
            minLines: 2,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Escribe o dicta…'),
            onChanged: (_) => setState(() {}),
          ),
          if (_aviso != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _aviso!,
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
          if (orden != null) ...[
            const SizedBox(height: 12),
            Container(
              key: const Key('entendido'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: p.superficie,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Entendí → ${describir(orden, hoy)}',
                style: texto.bodyMedium?.copyWith(color: p.texto),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 64,
                height: 56,
                child: IconButton.filledTonal(
                  key: const Key('boton-microfono'),
                  tooltip: _escuchando ? 'Detener' : 'Dictar',
                  style: IconButton.styleFrom(
                    backgroundColor: _escuchando ? p.acento : p.superficie,
                    foregroundColor: _escuchando ? p.sobreAcento : p.texto,
                  ),
                  icon: Icon(_escuchando ? Icons.stop : Icons.mic_none),
                  onPressed: _microfono,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  key: const Key('boton-continuar-asistente'),
                  onPressed: orden == null
                      ? null
                      : () => Navigator.pop(context, orden),
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
