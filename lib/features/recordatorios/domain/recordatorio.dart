import 'package:asistente_app/core/fechas.dart';
import 'package:flutter/foundation.dart';

@immutable
class Recordatorio {
  const Recordatorio({
    required this.id,
    required this.titulo,
    required this.fecha,
    this.cadaMeses = 0,
    this.fichaId,
    this.familiarId,
    this.hecho = false,
  });

  factory Recordatorio.fromJson(Map<String, dynamic> json) => Recordatorio(
    id: json['id'] as String,
    titulo: json['titulo'] as String,
    fecha: DateTime.parse(json['fecha'] as String),
    cadaMeses: json['cadaMeses'] as int? ?? 0,
    fichaId: json['fichaId'] as String?,
    familiarId: json['familiarId'] as String?,
    hecho: json['hecho'] as bool? ?? false,
  );

  final String id;
  final String titulo;
  final DateTime fecha;

  /// Cada cuántos meses se repite; 0 si es de una sola vez.
  final int cadaMeses;
  final String? fichaId;
  final String? familiarId;
  final bool hecho;

  bool get seRepite => cadaMeses > 0;

  /// Al cumplirlo: si se repite pasa a la siguiente fecha, si no queda hecho.
  Recordatorio cumplido() => seRepite
      ? _copia(fecha: sumarMeses(fecha, cadaMeses))
      : _copia(hecho: true);

  Recordatorio _copia({DateTime? fecha, bool? hecho}) => Recordatorio(
    id: id,
    titulo: titulo,
    fecha: fecha ?? this.fecha,
    cadaMeses: cadaMeses,
    fichaId: fichaId,
    familiarId: familiarId,
    hecho: hecho ?? this.hecho,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'fecha': fecha.toIso8601String(),
    'cadaMeses': cadaMeses,
    'fichaId': fichaId,
    'familiarId': familiarId,
    'hecho': hecho,
  };
}

/// "Cada mes", "Cada 6 meses", "Cada año".
String textoRepeticion(int cadaMeses) => switch (cadaMeses) {
  0 => 'Una sola vez',
  1 => 'Cada mes',
  12 => 'Cada año',
  _ => 'Cada $cadaMeses meses',
};
