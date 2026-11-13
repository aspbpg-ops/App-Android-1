import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/core/widgets/campo_fecha.dart';
import 'package:asistente_app/features/fichas/domain/ficha.dart';
import 'package:asistente_app/features/recordatorios/domain/recordatorio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asistente para crear una ficha: qué es, cómo se llama y qué recordar.
class NuevaFichaPage extends ConsumerStatefulWidget {
  const NuevaFichaPage({this.tipoInicial, this.nombreInicial = '', super.key});

  /// Si ya se sabe qué es (por ejemplo, dictado), salta la primera pregunta.
  final TipoFicha? tipoInicial;
  final String nombreInicial;

  @override
  ConsumerState<NuevaFichaPage> createState() => _NuevaFichaPageState();
}

class _NuevaFichaPageState extends ConsumerState<NuevaFichaPage> {
  var _paso = 0;
  TipoFicha? _tipo;
  late String _nombre = widget.nombreInicial;

  /// Fecha elegida para cada sugerencia aceptada.
  final _fechas = <Sugerencia, DateTime>{};
  final _aceptadas = <Sugerencia>{};

  bool get _tieneSugerencias => _tipo?.sugerencias.isNotEmpty ?? false;
  bool get _esUltimo => _paso == 2 || (_paso == 1 && !_tieneSugerencias);

  @override
  void initState() {
    super.initState();
    final tipo = widget.tipoInicial;
    if (tipo != null) _elegirTipo(tipo);
  }

  void _elegirTipo(TipoFicha tipo) {
    final hoy = soloDia(ref.read(relojProvider)());
    setState(() {
      _tipo = tipo;
      _aceptadas
        ..clear()
        ..addAll(tipo.sugerencias);
      _fechas
        ..clear()
        ..addEntries([
          for (final s in tipo.sugerencias)
            MapEntry(s, sumarMeses(hoy, s.cadaMeses)),
        ]);
      _paso = 1;
    });
  }

  void _guardar() {
    ref
        .read(datosProvider.notifier)
        .agregarFicha(
          tipo: _tipo!,
          nombre: _nombre,
          recordatorios: [
            for (final s in _tipo!.sugerencias)
              if (_aceptadas.contains(s))
                RecordatorioNuevo(
                  titulo: s.titulo,
                  fecha: _fechas[s]!,
                  cadaMeses: s.cadaMeses,
                ),
          ],
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Atrás',
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              _paso == 0 ? Navigator.pop(context) : setState(() => _paso--),
        ),
        title: Text('Nueva ficha · Paso ${_paso + 1} de 3'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_paso + 1) / 3),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: switch (_paso) {
                  0 => [
                    Text(
                      '¿Qué quieres registrar?',
                      style: texto.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    for (final tipo in TipoFicha.values)
                      Card(
                        child: ListTile(
                          key: Key('tipo-${tipo.name}'),
                          leading: Text(
                            tipo.icono,
                            style: const TextStyle(fontSize: 32),
                          ),
                          title: Text(tipo.etiqueta),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _elegirTipo(tipo),
                        ),
                      ),
                  ],
                  1 => [
                    Text('¿Cómo le llamamos?', style: texto.headlineMedium),
                    const SizedBox(height: 12),
                    Text(
                      'Un nombre corto para reconocerlo.',
                      style: texto.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const Key('campo-nombre-ficha'),
                      initialValue: _nombre,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        hintText: _tipo!.ejemplo,
                      ),
                      onChanged: (valor) => setState(() => _nombre = valor),
                    ),
                  ],
                  _ => [
                    Text('¿Qué te recuerdo?', style: texto.headlineMedium),
                    const SizedBox(height: 12),
                    Text(
                      'Esto es lo que suele olvidarse. Quita lo que no '
                      'aplique y ajusta la fecha de la próxima vez.',
                      style: texto.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    for (final s in _tipo!.sugerencias)
                      _SugerenciaCard(
                        sugerencia: s,
                        aceptada: _aceptadas.contains(s),
                        fecha: _fechas[s]!,
                        onAceptar: (aceptar) => setState(
                          () => aceptar
                              ? _aceptadas.add(s)
                              : _aceptadas.remove(s),
                        ),
                        onFecha: (fecha) => setState(() => _fechas[s] = fecha),
                      ),
                  ],
                },
              ),
            ),
            if (_paso > 0)
              Padding(
                padding: const EdgeInsets.all(24),
                child: FilledButton(
                  key: const Key('boton-continuar-ficha'),
                  onPressed: _nombre.trim().isEmpty
                      ? null
                      : _esUltimo
                      ? _guardar
                      : () {
                          FocusScope.of(context).unfocus();
                          setState(() => _paso = 2);
                        },
                  child: Text(_esUltimo ? 'Guardar ficha' : 'Continuar'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SugerenciaCard extends ConsumerWidget {
  const _SugerenciaCard({
    required this.sugerencia,
    required this.aceptada,
    required this.fecha,
    required this.onAceptar,
    required this.onFecha,
  });

  final Sugerencia sugerencia;
  final bool aceptada;
  final DateTime fecha;
  final ValueChanged<bool> onAceptar;
  final ValueChanged<DateTime> onFecha;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoy = soloDia(ref.watch(relojProvider)());
    return Card(
      child: Column(
        children: [
          CheckboxListTile(
            value: aceptada,
            title: Text(sugerencia.titulo),
            subtitle: Text(textoRepeticion(sugerencia.cadaMeses)),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (valor) => onAceptar(valor ?? false),
          ),
          if (aceptada)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: CampoFecha(
                etiqueta: 'Próxima vez',
                fecha: fecha,
                primera: hoy,
                ultima: DateTime(hoy.year + 10, 12, 31),
                onCambio: onFecha,
              ),
            ),
        ],
      ),
    );
  }
}
