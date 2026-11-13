import 'package:asistente_app/core/datos/datos_app.dart';
import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/features/recordatorios/domain/recordatorio.dart';
import 'package:flutter/foundation.dart';

/// Una notificación programada en el celular.
@immutable
class Aviso {
  const Aviso({
    required this.momento,
    required this.titulo,
    required this.cuerpo,
  });

  final DateTime momento;
  final String titulo;
  final String cuerpo;

  @override
  bool operator ==(Object other) =>
      other is Aviso &&
      other.momento == momento &&
      other.titulo == titulo &&
      other.cuerpo == cuerpo;

  @override
  int get hashCode => Object.hash(momento, titulo, cuerpo);

  @override
  String toString() => 'Aviso($momento, $titulo, $cuerpo)';
}

/// Hora en que avisa un recordatorio sin hora.
const int horaPorDefecto = 9 * 60;

/// Android limita las alarmas por app; se programan las más próximas.
const maximoAvisos = 60;

/// Calcula qué notificaciones deben quedar programadas a partir de [ahora].
///
/// Se recalcula cada vez que cambian los datos, así que los repetidos solo
/// llevan su próxima fecha y el cierre del día usa los pendientes actuales.
List<Aviso> planearAvisos(DatosApp datos, DateTime ahora) {
  final avisos = <Aviso>[];
  final limite = ahora.add(const Duration(days: 60));

  for (final r in datos.pendientes) {
    final momento = r.fecha.add(Duration(minutes: r.hora ?? horaPorDefecto));
    if (momento.isAfter(ahora) && momento.isBefore(limite)) {
      avisos.add(
        Aviso(
          momento: momento,
          titulo: r.titulo,
          cuerpo: r.hora == null
              ? 'Para hoy'
              : 'Hoy a las ${textoHora(r.hora!)}',
        ),
      );
    }
    // Un día antes del cumpleaños, para alcanzar a comprar algo.
    if (r.familiarId != null) {
      final antes = r.fecha
          .subtract(const Duration(days: 1))
          .add(const Duration(minutes: horaPorDefecto));
      if (antes.isAfter(ahora) && antes.isBefore(limite)) {
        avisos.add(
          Aviso(momento: antes, titulo: 'Mañana: ${r.titulo}', cuerpo: '🎁'),
        );
      }
    }
  }

  final perfil = datos.perfil;
  if (perfil != null) {
    final notas = datos.notas.where((n) => n.pendiente).length;
    for (var dia = 0; dia < 7; dia++) {
      final fecha = soloDia(ahora).add(Duration(days: dia));
      final momento = fecha.add(Duration(minutes: perfil.horaResumen));
      if (!momento.isAfter(ahora)) continue;
      final cuerpo = _resumen(
        notas: notas,
        manana: datos.pendientesDelDia(fecha.add(const Duration(days: 1))),
      );
      if (cuerpo != null) {
        avisos.add(
          Aviso(momento: momento, titulo: 'Cierre del día', cuerpo: cuerpo),
        );
      }
    }
  }

  avisos.sort((a, b) => a.momento.compareTo(b.momento));
  return avisos.take(maximoAvisos).toList();
}

String? _resumen({required int notas, required List<Recordatorio> manana}) {
  final partes = [
    if (notas == 1) 'Tienes 1 nota pendiente.',
    if (notas > 1) 'Tienes $notas notas pendientes.',
    if (manana.isNotEmpty) _textoManana(manana),
  ];
  return partes.isEmpty ? null : partes.join(' ');
}

String _textoManana(List<Recordatorio> manana) {
  final titulos = manana.take(3).map((r) => r.titulo).join(', ');
  final resto = manana.length > 3 ? ' y ${manana.length - 3} más' : '';
  return 'Mañana: $titulos$resto.';
}
