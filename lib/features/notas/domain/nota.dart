import 'package:flutter/foundation.dart';

/// Categorías iniciales; la persona puede escribir otras.
const categoriasBase = [
  'Personal',
  'Trabajo',
  'Casa',
  'Rentas',
  'Compras',
  'Ideas',
];

/// Algo que se apunta al vuelo durante el día.
@immutable
class Nota {
  const Nota({
    required this.id,
    required this.texto,
    required this.categoria,
    required this.creada,
    this.pendiente = true,
  });

  factory Nota.fromJson(Map<String, dynamic> json) => Nota(
    id: json['id'] as String,
    texto: json['texto'] as String,
    categoria: json['categoria'] as String,
    creada: DateTime.parse(json['creada'] as String),
    pendiente: json['pendiente'] as bool? ?? true,
  );

  final String id;
  final String texto;
  final String categoria;
  final DateTime creada;

  /// Las notas pendientes aparecen en el resumen del final del día.
  final bool pendiente;

  Nota copyWith({String? texto, String? categoria, bool? pendiente}) => Nota(
    id: id,
    texto: texto ?? this.texto,
    categoria: categoria ?? this.categoria,
    creada: creada,
    pendiente: pendiente ?? this.pendiente,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'texto': texto,
    'categoria': categoria,
    'creada': creada.toIso8601String(),
    'pendiente': pendiente,
  };
}
