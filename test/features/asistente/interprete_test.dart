import 'package:asistente_app/features/asistente/domain/interprete.dart';
import 'package:asistente_app/features/asistente/domain/orden.dart';
import 'package:asistente_app/features/fichas/domain/ficha.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Jueves 12 de noviembre de 2026.
  final hoy = DateTime(2026, 11, 12, 19);

  group('fichas', () {
    test('entiende la compra de un auto', () {
      expect(
        interpretar('Hoy compré un auto nuevo', hoy),
        const CrearFicha(TipoFicha.auto),
      );
      expect(
        interpretar('me compré una camioneta', hoy),
        const CrearFicha(TipoFicha.auto),
      );
    });

    test('toma el nombre de la mascota', () {
      expect(
        interpretar('Adopté un perro que se llama rocky', hoy),
        const CrearFicha(TipoFicha.mascota, nombre: 'Rocky'),
      );
    });

    test('distingue departamento en renta de casa', () {
      expect(
        interpretar('Registra un departamento en renta', hoy),
        const CrearFicha(TipoFicha.renta),
      );
      expect(
        interpretar('compré una casa', hoy),
        const CrearFicha(TipoFicha.casa),
      );
    });
  });

  group('recordatorios', () {
    test('mañana y pasado mañana', () {
      expect(
        interpretar('Recuérdame mañana pagar la luz', hoy),
        CrearRecordatorio('Pagar la luz', fecha: DateTime(2026, 11, 13)),
      );
      expect(
        interpretar('recuérdame pasado mañana llamar a mamá', hoy),
        CrearRecordatorio('Llamar a mamá', fecha: DateTime(2026, 11, 14)),
      );
    });

    test('día de la semana y fecha con mes', () {
      expect(
        interpretar('Recuérdame el lunes ir al banco', hoy),
        CrearRecordatorio('Ir al banco', fecha: DateTime(2026, 11, 16)),
      );
      expect(
        interpretar('recuérdame que el 5 de marzo es el cumple de Ana', hoy),
        CrearRecordatorio('Es el cumple de Ana', fecha: DateTime(2027, 3, 5)),
      );
    });

    test('en N días o semanas', () {
      expect(
        interpretar('avísame en 3 días revisar la cotización', hoy),
        CrearRecordatorio(
          'Revisar la cotización',
          fecha: DateTime(2026, 11, 15),
        ),
      );
      expect(
        interpretar('recuérdame en 2 semanas cambiar el filtro', hoy),
        CrearRecordatorio('Cambiar el filtro', fecha: DateTime(2026, 11, 26)),
      );
    });

    test('entiende la hora', () {
      expect(
        interpretar('recuérdame mañana a las 10 llamar a mamá', hoy),
        CrearRecordatorio(
          'Llamar a mamá',
          fecha: DateTime(2026, 11, 13),
          hora: 600,
        ),
      );
      expect(
        interpretar('recuérdame el viernes a las 5 de la tarde ir al gym', hoy),
        CrearRecordatorio(
          'Ir al gym',
          fecha: DateTime(2026, 11, 13),
          hora: 17 * 60,
        ),
      );
      // Son las 19:00: "a las 8 de la mañana" ya pasó, va para mañana.
      expect(
        interpretar('recuérdame a las 8 de la mañana sacar la basura', hoy),
        CrearRecordatorio(
          'Sacar la basura',
          fecha: DateTime(2026, 11, 13),
          hora: 8 * 60,
        ),
      );
    });

    test('sin fecha deja que la persona la elija', () {
      expect(
        interpretar('recuérdame renovar el pasaporte', hoy),
        const CrearRecordatorio('Renovar el pasaporte'),
      );
    });
  });

  group('notas', () {
    test('clasifica por palabras clave', () {
      expect(
        interpretar('El inquilino del 3B reportó una fuga', hoy),
        const CrearNota('El inquilino del 3B reportó una fuga', 'Rentas'),
      );
      expect(
        interpretar('nota: preparar la junta con el cliente', hoy),
        const CrearNota('Preparar la junta con el cliente', 'Trabajo'),
      );
      expect(
        interpretar('comprar focos y pilas', hoy),
        const CrearNota('Comprar focos y pilas', 'Compras'),
      );
    });

    test('lo que no encaja va a Personal', () {
      expect(
        interpretar('hoy me sentí con mucha energía', hoy),
        const CrearNota('Hoy me sentí con mucha energía', 'Personal'),
      );
    });
  });
}
