import 'package:flutter/foundation.dart';

/// Etapa de vida que elige la persona; define qué se le sugiere primero.
enum EtapaDeVida {
  soltero('Vivo solo o sola', '🧍'),
  pareja('Vivo en pareja', '💑'),
  familia('Tengo familia con hijos', '👨‍👩‍👧');

  const EtapaDeVida(this.etiqueta, this.icono);

  final String etiqueta;
  final String icono;
}

const avataresDisponibles = [
  '🙂',
  '😎',
  '🧔',
  '👩',
  '👨',
  '🧑‍💼',
  '👩‍🦱',
  '🦸',
];

@immutable
class Perfil {
  const Perfil({
    required this.nombre,
    required this.avatar,
    required this.etapa,
    this.horaResumen = 21 * 60,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) => Perfil(
    nombre: json['nombre'] as String,
    avatar: json['avatar'] as String,
    etapa: EtapaDeVida.values.byName(json['etapa'] as String),
    horaResumen: json['horaResumen'] as int? ?? 21 * 60,
  );

  final String nombre;
  final String avatar;
  final EtapaDeVida etapa;

  /// Minutos desde la medianoche en que llega el cierre del día.
  final int horaResumen;

  Perfil copyWith({int? horaResumen}) => Perfil(
    nombre: nombre,
    avatar: avatar,
    etapa: etapa,
    horaResumen: horaResumen ?? this.horaResumen,
  );

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'avatar': avatar,
    'etapa': etapa.name,
    'horaResumen': horaResumen,
  };
}
