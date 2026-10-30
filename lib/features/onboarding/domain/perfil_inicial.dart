import 'package:flutter/foundation.dart';

/// Etapa de vida que elige la persona; define qué fichas se sugieren primero.
enum EtapaDeVida {
  soltero('Vivo solo o sola', '🧍'),
  pareja('Vivo en pareja', '💑'),
  familia('Tengo familia con hijos', '👨‍👩‍👧');

  const EtapaDeVida(this.etiqueta, this.icono);

  final String etiqueta;
  final String icono;
}

/// Avatares disponibles en la v1 (sin fotos, para no subir imágenes aún).
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

final _correoValido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool esCorreoValido(String correo) => _correoValido.hasMatch(correo.trim());

/// Lo que se captura en el onboarding paso a paso.
@immutable
class PerfilInicial {
  const PerfilInicial({
    this.nombre = '',
    this.avatar,
    this.etapa,
    this.correoInvitado,
    this.respaldoEntendido = false,
    this.completo = false,
  });

  final String nombre;
  final String? avatar;
  final EtapaDeVida? etapa;

  /// Correo de la otra cuenta del entorno compartido; `null` si lo deja
  /// para después.
  final String? correoInvitado;
  final bool respaldoEntendido;
  final bool completo;

  bool get nombreValido => nombre.trim().length >= 2;

  PerfilInicial copyWith({
    String? nombre,
    String? avatar,
    EtapaDeVida? etapa,
    String? Function()? correoInvitado,
    bool? respaldoEntendido,
    bool? completo,
  }) {
    return PerfilInicial(
      nombre: nombre ?? this.nombre,
      avatar: avatar ?? this.avatar,
      etapa: etapa ?? this.etapa,
      correoInvitado: correoInvitado != null
          ? correoInvitado()
          : this.correoInvitado,
      respaldoEntendido: respaldoEntendido ?? this.respaldoEntendido,
      completo: completo ?? this.completo,
    );
  }
}
