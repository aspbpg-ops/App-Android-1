import 'package:asistente_app/core/fechas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sumarMeses respeta el fin de mes y el cambio de año', () {
    expect(sumarMeses(DateTime(2027, 1, 31), 1), DateTime(2027, 2, 28));
    expect(sumarMeses(DateTime(2026, 11, 15), 6), DateTime(2027, 5, 15));
    expect(sumarMeses(DateTime(2026, 12, 5), 12), DateTime(2027, 12, 5));
  });

  test('cuantoFalta habla en días', () {
    final hoy = DateTime(2026, 11, 12, 19);
    expect(cuantoFalta(DateTime(2026, 11, 12), hoy), 'Hoy');
    expect(cuantoFalta(DateTime(2026, 11, 13), hoy), 'Mañana');
    expect(cuantoFalta(DateTime(2026, 11, 20), hoy), 'En 8 días');
    expect(cuantoFalta(DateTime(2026, 11, 9), hoy), 'Hace 3 días');
  });

  test('fechaCorta omite el año si es el actual', () {
    final hoy = DateTime(2026, 11, 12);
    expect(fechaCorta(DateTime(2026, 11, 15), hoy), '15 nov');
    expect(fechaCorta(DateTime(2027, 1, 15), hoy), '15 ene 2027');
  });

  test('proximoCumple cae este año o el siguiente', () {
    final hoy = DateTime(2026, 11, 12);
    expect(proximoCumple(DateTime(1990, 12, 24), hoy), DateTime(2026, 12, 24));
    expect(proximoCumple(DateTime(1990, 3, 5), hoy), DateTime(2027, 3, 5));
    expect(proximoCumple(DateTime(1990, 11, 12), hoy), DateTime(2026, 11, 12));
    expect(proximoCumple(DateTime(1992, 2, 29), hoy), DateTime(2027, 2, 28));
  });
}
