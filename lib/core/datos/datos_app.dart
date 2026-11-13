import 'package:asistente_app/features/familiares/domain/familiar.dart';
import 'package:asistente_app/features/fichas/domain/ficha.dart';
import 'package:asistente_app/features/notas/domain/nota.dart';
import 'package:asistente_app/features/perfil/domain/perfil.dart';
import 'package:asistente_app/features/recordatorios/domain/recordatorio.dart';
import 'package:flutter/foundation.dart';

/// Los datos que la app guarda en el celular.
@immutable
class DatosApp {
  const DatosApp({
    this.perfil,
    this.fichas = const [],
    this.familiares = const [],
    this.recordatorios = const [],
    this.notas = const [],
  });

  factory DatosApp.fromJson(Map<String, dynamic> json) {
    List<T> lista<T>(String clave, T Function(Map<String, dynamic>) crear) => [
      for (final item in json[clave] as List<dynamic>? ?? const [])
        crear(item as Map<String, dynamic>),
    ];
    final perfil = json['perfil'] as Map<String, dynamic>?;
    return DatosApp(
      perfil: perfil == null ? null : Perfil.fromJson(perfil),
      fichas: lista('fichas', Ficha.fromJson),
      familiares: lista('familiares', Familiar.fromJson),
      recordatorios: lista('recordatorios', Recordatorio.fromJson),
      notas: lista('notas', Nota.fromJson),
    );
  }

  final Perfil? perfil;
  final List<Ficha> fichas;
  final List<Familiar> familiares;
  final List<Recordatorio> recordatorios;
  final List<Nota> notas;

  /// Categorías base más las que la persona ha creado, sin repetir.
  List<String> get categorias =>
      {...categoriasBase, for (final n in notas) n.categoria}.toList();

  /// Pendientes de un día concreto, para el calendario.
  List<Recordatorio> pendientesDelDia(DateTime dia) => pendientes
      .where(
        (r) =>
            r.fecha.year == dia.year &&
            r.fecha.month == dia.month &&
            r.fecha.day == dia.day,
      )
      .toList();

  /// Recordatorios sin cumplir, del más próximo al más lejano.
  List<Recordatorio> get pendientes =>
      recordatorios.where((r) => !r.hecho).toList()
        ..sort((a, b) => a.momento.compareTo(b.momento));

  List<Recordatorio> pendientesDeFicha(String fichaId) =>
      pendientes.where((r) => r.fichaId == fichaId).toList();

  DatosApp copyWith({
    Perfil? perfil,
    List<Ficha>? fichas,
    List<Familiar>? familiares,
    List<Recordatorio>? recordatorios,
    List<Nota>? notas,
  }) => DatosApp(
    perfil: perfil ?? this.perfil,
    fichas: fichas ?? this.fichas,
    familiares: familiares ?? this.familiares,
    recordatorios: recordatorios ?? this.recordatorios,
    notas: notas ?? this.notas,
  );

  Map<String, dynamic> toJson() => {
    'perfil': perfil?.toJson(),
    'fichas': [for (final f in fichas) f.toJson()],
    'familiares': [for (final f in familiares) f.toJson()],
    'recordatorios': [for (final r in recordatorios) r.toJson()],
    'notas': [for (final n in notas) n.toJson()],
  };
}
