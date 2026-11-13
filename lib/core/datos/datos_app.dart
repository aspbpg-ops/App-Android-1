import 'package:asistente_app/features/familiares/domain/familiar.dart';
import 'package:asistente_app/features/fichas/domain/ficha.dart';
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
    );
  }

  final Perfil? perfil;
  final List<Ficha> fichas;
  final List<Familiar> familiares;
  final List<Recordatorio> recordatorios;

  /// Recordatorios sin cumplir, del más próximo al más lejano.
  List<Recordatorio> get pendientes =>
      recordatorios.where((r) => !r.hecho).toList()
        ..sort((a, b) => a.fecha.compareTo(b.fecha));

  List<Recordatorio> pendientesDeFicha(String fichaId) =>
      pendientes.where((r) => r.fichaId == fichaId).toList();

  DatosApp copyWith({
    Perfil? perfil,
    List<Ficha>? fichas,
    List<Familiar>? familiares,
    List<Recordatorio>? recordatorios,
  }) => DatosApp(
    perfil: perfil ?? this.perfil,
    fichas: fichas ?? this.fichas,
    familiares: familiares ?? this.familiares,
    recordatorios: recordatorios ?? this.recordatorios,
  );

  Map<String, dynamic> toJson() => {
    'perfil': perfil?.toJson(),
    'fichas': [for (final f in fichas) f.toJson()],
    'familiares': [for (final f in familiares) f.toJson()],
    'recordatorios': [for (final r in recordatorios) r.toJson()],
  };
}
