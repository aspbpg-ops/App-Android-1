import 'package:flutter/foundation.dart';

const parentescos = [
  'Pareja',
  'Hijo o hija',
  'Mamá',
  'Papá',
  'Hermano o hermana',
  'Amigo o amiga',
  'Jefe o compañero',
  'Otro',
];

@immutable
class Familiar {
  const Familiar({
    required this.id,
    required this.nombre,
    required this.parentesco,
    this.cumple,
    this.telefono = '',
  });

  factory Familiar.fromJson(Map<String, dynamic> json) => Familiar(
    id: json['id'] as String,
    nombre: json['nombre'] as String,
    parentesco: json['parentesco'] as String,
    cumple: json['cumple'] == null
        ? null
        : DateTime.parse(json['cumple'] as String),
    telefono: json['telefono'] as String? ?? '',
  );

  final String id;
  final String nombre;
  final String parentesco;

  /// Fecha de nacimiento; solo se usan el día y el mes.
  final DateTime? cumple;
  final String telefono;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'parentesco': parentesco,
    'cumple': cumple?.toIso8601String(),
    'telefono': telefono,
  };
}
