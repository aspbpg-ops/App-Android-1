import 'dart:async';

import 'package:asistente_app/core/datos/almacen.dart';
import 'package:asistente_app/core/datos/datos_app.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/features/familiares/domain/familiar.dart';
import 'package:asistente_app/features/fichas/domain/ficha.dart';
import 'package:asistente_app/features/notas/domain/nota.dart';
import 'package:asistente_app/features/perfil/domain/perfil.dart';
import 'package:asistente_app/features/recordatorios/domain/recordatorio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fecha y hora actuales; se reemplaza en pruebas.
final relojProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Recordatorio que la persona aceptó al crear una ficha.
@immutable
class RecordatorioNuevo {
  const RecordatorioNuevo({
    required this.titulo,
    required this.fecha,
    this.cadaMeses = 0,
    this.hora,
  });

  final String titulo;
  final DateTime fecha;
  final int cadaMeses;
  final int? hora;
}

class DatosController extends Notifier<DatosApp> {
  var _consecutivo = 0;

  @override
  DatosApp build() => ref.watch(almacenProvider).leer();

  DateTime get _ahora => ref.read(relojProvider)();

  String _nuevoId() =>
      '${_ahora.microsecondsSinceEpoch.toRadixString(36)}-${_consecutivo++}';

  void _guardar(DatosApp datos) {
    state = datos;
    unawaited(ref.read(almacenProvider).guardar(datos));
  }

  void guardarPerfil(Perfil perfil) => _guardar(state.copyWith(perfil: perfil));

  /// Crea la ficha junto con los recordatorios que la persona aceptó.
  Ficha agregarFicha({
    required TipoFicha tipo,
    required String nombre,
    List<RecordatorioNuevo> recordatorios = const [],
  }) {
    final ficha = Ficha(id: _nuevoId(), tipo: tipo, nombre: nombre.trim());
    _guardar(
      state.copyWith(
        fichas: [...state.fichas, ficha],
        recordatorios: [
          ...state.recordatorios,
          for (final r in recordatorios)
            Recordatorio(
              id: _nuevoId(),
              titulo: r.titulo,
              fecha: soloDia(r.fecha),
              cadaMeses: r.cadaMeses,
              hora: r.hora,
              fichaId: ficha.id,
            ),
        ],
      ),
    );
    return ficha;
  }

  void borrarFicha(String id) => _guardar(
    state.copyWith(
      fichas: state.fichas.where((f) => f.id != id).toList(),
      recordatorios: state.recordatorios.where((r) => r.fichaId != id).toList(),
    ),
  );

  /// Guarda al familiar y, si hay cumpleaños, su recordatorio de cada año.
  void agregarFamiliar({
    required String nombre,
    required String parentesco,
    DateTime? cumple,
    String telefono = '',
  }) {
    final familiar = Familiar(
      id: _nuevoId(),
      nombre: nombre.trim(),
      parentesco: parentesco,
      cumple: cumple,
      telefono: telefono.trim(),
    );
    _guardar(
      state.copyWith(
        familiares: [...state.familiares, familiar],
        recordatorios: [
          ...state.recordatorios,
          if (cumple != null)
            Recordatorio(
              id: _nuevoId(),
              titulo: 'Cumpleaños de ${familiar.nombre}',
              fecha: proximoCumple(cumple, _ahora),
              cadaMeses: 12,
              familiarId: familiar.id,
            ),
        ],
      ),
    );
  }

  void borrarFamiliar(String id) => _guardar(
    state.copyWith(
      familiares: state.familiares.where((f) => f.id != id).toList(),
      recordatorios: state.recordatorios
          .where((r) => r.familiarId != id)
          .toList(),
    ),
  );

  void agregarRecordatorio(RecordatorioNuevo nuevo, {String? fichaId}) =>
      _guardar(
        state.copyWith(
          recordatorios: [
            ...state.recordatorios,
            Recordatorio(
              id: _nuevoId(),
              titulo: nuevo.titulo.trim(),
              fecha: soloDia(nuevo.fecha),
              cadaMeses: nuevo.cadaMeses,
              hora: nuevo.hora,
              fichaId: fichaId,
            ),
          ],
        ),
      );

  /// Marca como hecho; los que se repiten pasan a su siguiente fecha.
  void cumplir(String id) => _guardar(
    state.copyWith(
      recordatorios: [
        for (final r in state.recordatorios)
          if (r.id == id) r.cumplido() else r,
      ],
    ),
  );

  /// Deshace un [cumplir]: regresa el recordatorio como estaba.
  void restaurar(Recordatorio anterior) => _guardar(
    state.copyWith(
      recordatorios: [
        for (final r in state.recordatorios)
          if (r.id == anterior.id) anterior else r,
      ],
    ),
  );

  void borrarRecordatorio(String id) => _guardar(
    state.copyWith(
      recordatorios: state.recordatorios.where((r) => r.id != id).toList(),
    ),
  );

  Nota agregarNota({required String texto, required String categoria}) {
    final nota = Nota(
      id: _nuevoId(),
      texto: texto.trim(),
      categoria: categoria.trim(),
      creada: _ahora,
    );
    _guardar(state.copyWith(notas: [nota, ...state.notas]));
    return nota;
  }

  void editarNota(Nota nota) => _guardar(
    state.copyWith(
      notas: [
        for (final n in state.notas)
          if (n.id == nota.id) nota else n,
      ],
    ),
  );

  void alternarNotaPendiente(String id) => _guardar(
    state.copyWith(
      notas: [
        for (final n in state.notas)
          if (n.id == id) n.copyWith(pendiente: !n.pendiente) else n,
      ],
    ),
  );

  void borrarNota(String id) => _guardar(
    state.copyWith(notas: state.notas.where((n) => n.id != id).toList()),
  );

  void borrarTodo() => _guardar(const DatosApp());
}

final datosProvider = NotifierProvider<DatosController, DatosApp>(
  DatosController.new,
);
