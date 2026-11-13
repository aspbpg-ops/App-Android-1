import 'package:flutter/foundation.dart';

/// Recordatorio que una plantilla propone al crear una ficha.
@immutable
class Sugerencia {
  const Sugerencia(this.titulo, {required this.cadaMeses});

  final String titulo;

  /// Cada cuántos meses se repite.
  final int cadaMeses;
}

/// Tipos de ficha con su plantilla de recordatorios, pensada para México.
enum TipoFicha {
  auto('Auto', '🚗', 'Ej. Versa gris', [
    Sugerencia('Verificación vehicular', cadaMeses: 6),
    Sugerencia('Pago de tenencia o refrendo', cadaMeses: 12),
    Sugerencia('Renovar seguro del auto', cadaMeses: 12),
    Sugerencia('Servicio y cambio de aceite', cadaMeses: 6),
    Sugerencia('Calibrar llantas y revisar refacción', cadaMeses: 1),
  ]),
  casa('Casa', '🏠', 'Ej. Mi casa', [
    Sugerencia('Pago del predial', cadaMeses: 12),
    Sugerencia('Recibo de luz', cadaMeses: 2),
    Sugerencia('Recibo de agua', cadaMeses: 2),
    Sugerencia('Internet y teléfono', cadaMeses: 1),
    Sugerencia('Mantenimiento general', cadaMeses: 6),
  ]),
  mascota('Mascota', '🐶', 'Ej. Rocky', [
    Sugerencia('Vacunas', cadaMeses: 12),
    Sugerencia('Desparasitación', cadaMeses: 3),
    Sugerencia('Baño y corte', cadaMeses: 1),
    Sugerencia('Revisión con el veterinario', cadaMeses: 12),
  ]),
  renta('Departamento en renta', '🏢', 'Ej. Depto. Centro 3B', [
    Sugerencia('Cobrar la renta', cadaMeses: 1),
    Sugerencia('Pago del predial', cadaMeses: 12),
    Sugerencia('Renovación de contrato', cadaMeses: 12),
    Sugerencia('Revisión de mantenimiento', cadaMeses: 6),
  ]),
  otro('Otra cosa', '📌', 'Ej. Gimnasio', []);

  const TipoFicha(this.etiqueta, this.icono, this.ejemplo, this.sugerencias);

  final String etiqueta;
  final String icono;
  final String ejemplo;
  final List<Sugerencia> sugerencias;
}

/// Algo importante de la vida de la persona: su auto, su casa, su mascota.
@immutable
class Ficha {
  const Ficha({required this.id, required this.tipo, required this.nombre});

  factory Ficha.fromJson(Map<String, dynamic> json) => Ficha(
    id: json['id'] as String,
    tipo: TipoFicha.values.byName(json['tipo'] as String),
    nombre: json['nombre'] as String,
  );

  final String id;
  final TipoFicha tipo;
  final String nombre;

  Map<String, dynamic> toJson() => {
    'id': id,
    'tipo': tipo.name,
    'nombre': nombre,
  };
}
