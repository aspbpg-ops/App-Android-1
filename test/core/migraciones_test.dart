import 'dart:convert';
import 'dart:io';

import 'package:asistente_app/core/datos/almacen.dart';
import 'package:asistente_app/core/datos/datos_app.dart';
import 'package:asistente_app/core/datos/migraciones.dart';
import 'package:asistente_app/features/fichas/domain/ficha.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Datos tal como los guardaban versiones anteriores de la app. Cada vez que
/// cambie el formato se agrega aquí un archivo nuevo y nunca se borra uno.
const _versionesAnteriores = ['test/fixtures/datos_compilacion_3.json'];

void main() {
  for (final ruta in _versionesAnteriores) {
    group(ruta, () {
      late String texto;
      setUp(() => texto = File(ruta).readAsStringSync());

      test('se lee sin perder nada esencial', () async {
        SharedPreferences.setMockInitialValues({AlmacenLocal.clave: texto});
        final prefs = await SharedPreferences.getInstance();
        final datos = AlmacenLocal(prefs).leer();

        expect(datos.perfil!.nombre, 'Alex');
        expect(datos.perfil!.horaResumen, 21 * 60);
        expect(datos.fichas.map((f) => f.nombre), [
          'Versa gris',
          'Depto. Centro 3B',
        ]);
        expect(datos.fichas.last.tipo, TipoFicha.renta);
        expect(datos.familiares.single.telefono, '55 1234 5678');
        expect(datos.familiares.single.cumple, DateTime(1990, 3, 5));
        expect(datos.recordatorios, hasLength(3));
        expect(datos.recordatorios.first.fecha, DateTime(2027, 1, 15));
        expect(datos.recordatorios.first.cadaMeses, 6);
        expect(datos.recordatorios.last.hecho, isTrue);
        expect(datos.pendientes, hasLength(2));
        expect(datos.notas, isEmpty);
      });

      test('deja respaldo del original y guarda ya migrado', () async {
        SharedPreferences.setMockInitialValues({AlmacenLocal.clave: texto});
        final prefs = await SharedPreferences.getInstance();
        AlmacenLocal(prefs).leer();
        await Future<void>.delayed(Duration.zero);

        expect(prefs.getString('${AlmacenLocal.clave}_respaldo_v0'), texto);
        final guardado = jsonDecode(
          prefs.getString(AlmacenLocal.clave)!,
        ) as Map<String, dynamic>;
        expect(versionDe(guardado), versionDatos);
      });

      test('leer, guardar y volver a leer da lo mismo', () async {
        SharedPreferences.setMockInitialValues({AlmacenLocal.clave: texto});
        final prefs = await SharedPreferences.getInstance();
        final almacen = AlmacenLocal(prefs);
        final primera = almacen.leer();
        await almacen.guardar(primera);
        final segunda = almacen.leer();
        expect(jsonEncode(segunda.toJson()), jsonEncode(primera.toJson()));
      });
    });
  }

  test('lo que se guarda hoy lleva la versión actual', () {
    expect(const DatosApp().toJson()['version'], versionDatos);
  });
}
