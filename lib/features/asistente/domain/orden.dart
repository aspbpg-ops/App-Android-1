import 'package:asistente_app/features/fichas/domain/ficha.dart';
import 'package:flutter/foundation.dart';

/// Lo que la app entendió de una frase dictada: el "lenguaje interno".
@immutable
sealed class Orden {
  const Orden();
}

/// "Compré un auto nuevo" → abrir el asistente de ficha de ese tipo.
class CrearFicha extends Orden {
  const CrearFicha(this.tipo, {this.nombre = ''});

  final TipoFicha tipo;

  /// Nombre sugerido si la frase lo trae ("un perro que se llama Rocky").
  final String nombre;

  @override
  bool operator ==(Object other) =>
      other is CrearFicha && other.tipo == tipo && other.nombre == nombre;

  @override
  int get hashCode => Object.hash(tipo, nombre);

  @override
  String toString() => 'CrearFicha($tipo, $nombre)';
}

/// "Recuérdame mañana pagar la luz" → recordatorio con fecha.
class CrearRecordatorio extends Orden {
  const CrearRecordatorio(this.titulo, {this.fecha, this.hora});

  final String titulo;

  /// `null` si la frase no dice cuándo; la persona la elige después.
  final DateTime? fecha;

  /// Minutos desde la medianoche, si la frase dice la hora.
  final int? hora;

  @override
  bool operator ==(Object other) =>
      other is CrearRecordatorio &&
      other.titulo == titulo &&
      other.fecha == fecha &&
      other.hora == hora;

  @override
  int get hashCode => Object.hash(titulo, fecha, hora);

  @override
  String toString() => 'CrearRecordatorio($titulo, $fecha, $hora)';
}

/// Cualquier otra cosa se guarda como nota en la categoría que mejor encaje.
class CrearNota extends Orden {
  const CrearNota(this.texto, this.categoria);

  final String texto;
  final String categoria;

  @override
  bool operator ==(Object other) =>
      other is CrearNota &&
      other.texto == texto &&
      other.categoria == categoria;

  @override
  int get hashCode => Object.hash(texto, categoria);

  @override
  String toString() => 'CrearNota($texto, $categoria)';
}
