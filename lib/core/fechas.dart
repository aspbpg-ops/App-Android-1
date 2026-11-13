import 'dart:math';

const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

DateTime soloDia(DateTime f) => DateTime(f.year, f.month, f.day);

/// "5 de marzo de 2027".
String fechaLarga(DateTime f) =>
    '${f.day} de ${_meses[f.month - 1]} de ${f.year}';

/// "5 mar", o "5 mar 2027" si cae en un año distinto al de [hoy].
String fechaCorta(DateTime f, DateTime hoy) {
  final base = '${f.day} ${_meses[f.month - 1].substring(0, 3)}';
  return f.year == hoy.year ? base : '$base ${f.year}';
}

/// "5 de marzo", para cumpleaños.
String diaYMes(DateTime f) => '${f.day} de ${_meses[f.month - 1]}';

/// Suma meses respetando el fin de mes (31 de enero + 1 mes = 28 de febrero).
DateTime sumarMeses(DateTime f, int meses) {
  final indice = f.month - 1 + meses;
  final anio = f.year + (indice / 12).floor();
  final mes = indice % 12 + 1;
  final ultimoDia = DateTime(anio, mes + 1, 0).day;
  return DateTime(anio, mes, min(f.day, ultimoDia));
}

/// Días de calendario entre [hoy] y [fecha]; negativo si ya pasó.
int diasHasta(DateTime fecha, DateTime hoy) {
  final a = DateTime.utc(fecha.year, fecha.month, fecha.day);
  final b = DateTime.utc(hoy.year, hoy.month, hoy.day);
  return a.difference(b).inDays;
}

/// "Hoy", "Mañana", "En 5 días", "Hace 2 días".
String cuantoFalta(DateTime fecha, DateTime hoy) {
  final dias = diasHasta(fecha, hoy);
  return switch (dias) {
    0 => 'Hoy',
    1 => 'Mañana',
    -1 => 'Ayer',
    > 1 => 'En $dias días',
    _ => 'Hace ${-dias} días',
  };
}

/// Próxima vez que se cumple años a partir de [hoy] (incluye hoy).
DateTime proximoCumple(DateTime nacimiento, DateTime hoy) {
  // Quien nació un 29 de febrero festeja el 28 en años no bisiestos.
  DateTime cumpleEn(int anio) {
    final ultimoDia = DateTime(anio, nacimiento.month + 1, 0).day;
    return DateTime(anio, nacimiento.month, min(nacimiento.day, ultimoDia));
  }

  final base = soloDia(hoy);
  final esteAnio = cumpleEn(base.year);
  return esteAnio.isBefore(base) ? cumpleEn(base.year + 1) : esteAnio;
}
