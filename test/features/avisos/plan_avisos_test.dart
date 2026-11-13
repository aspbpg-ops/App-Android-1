import 'package:asistente_app/core/datos/datos_app.dart';
import 'package:asistente_app/features/avisos/domain/plan_avisos.dart';
import 'package:asistente_app/features/notas/domain/nota.dart';
import 'package:asistente_app/features/perfil/domain/perfil.dart';
import 'package:asistente_app/features/recordatorios/domain/recordatorio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ahora = DateTime(2026, 11, 12, 19);
  const perfil = Perfil(
    nombre: 'Alex',
    avatar: '😎',
    etapa: EtapaDeVida.pareja,
  );

  Recordatorio rec(
    String titulo,
    DateTime fecha, {
    int? hora,
    String? familiarId,
    bool hecho = false,
  }) => Recordatorio(
    id: titulo,
    titulo: titulo,
    fecha: fecha,
    hora: hora,
    familiarId: familiarId,
    hecho: hecho,
  );

  test('avisa a su hora, o a las 9 si no tiene, y omite lo pasado', () {
    final avisos = planearAvisos(
      DatosApp(
        recordatorios: [
          rec('Llamar a mamá', DateTime(2026, 11, 13), hora: 600),
          rec('Pagar la luz', DateTime(2026, 11, 14)),
          rec('Ya pasó', DateTime(2026, 11, 12), hora: 600),
          rec('Hecho', DateTime(2026, 11, 20), hecho: true),
        ],
      ),
      ahora,
    );
    expect(avisos, [
      Aviso(
        momento: DateTime(2026, 11, 13, 10),
        titulo: 'Llamar a mamá',
        cuerpo: 'Hoy a las 10:00',
      ),
      Aviso(
        momento: DateTime(2026, 11, 14, 9),
        titulo: 'Pagar la luz',
        cuerpo: 'Para hoy',
      ),
    ]);
  });

  test('los cumpleaños avisan también un día antes', () {
    final avisos = planearAvisos(
      DatosApp(
        recordatorios: [
          rec('Cumpleaños de Ana', DateTime(2026, 11, 20), familiarId: 'p1'),
        ],
      ),
      ahora,
    );
    expect(avisos.map((a) => a.momento), [
      DateTime(2026, 11, 19, 9),
      DateTime(2026, 11, 20, 9),
    ]);
    expect(avisos.first.titulo, 'Mañana: Cumpleaños de Ana');
  });

  test('el cierre del día junta notas pendientes y lo de mañana', () {
    final avisos = planearAvisos(
      DatosApp(
        perfil: perfil,
        notas: [
          Nota(id: 'n1', texto: 'a', categoria: 'Casa', creada: ahora),
          Nota(id: 'n2', texto: 'b', categoria: 'Casa', creada: ahora),
          Nota(
            id: 'n3',
            texto: 'c',
            categoria: 'Casa',
            creada: ahora,
            pendiente: false,
          ),
        ],
        recordatorios: [
          rec('Llamar a mamá', DateTime(2026, 11, 13), hora: 600),
        ],
      ),
      ahora,
    );
    final cierres = avisos.where((a) => a.titulo == 'Cierre del día');
    expect(cierres, hasLength(7));
    expect(cierres.first.momento, DateTime(2026, 11, 12, 21));
    expect(
      cierres.first.cuerpo,
      'Tienes 2 notas pendientes. Mañana: Llamar a mamá.',
    );
    expect(cierres.last.cuerpo, 'Tienes 2 notas pendientes.');
  });

  test('sin pendientes no hay cierre del día', () {
    expect(planearAvisos(const DatosApp(perfil: perfil), ahora), isEmpty);
  });

  test('respeta la hora elegida para el cierre', () {
    final avisos = planearAvisos(
      DatosApp(
        perfil: perfil.copyWith(horaResumen: 18 * 60),
        notas: [Nota(id: 'n', texto: 'a', categoria: 'Casa', creada: ahora)],
      ),
      ahora,
    );
    // Hoy a las 18:00 ya pasó: el primero es mañana.
    expect(avisos.first.momento, DateTime(2026, 11, 13, 18));
  });
}
