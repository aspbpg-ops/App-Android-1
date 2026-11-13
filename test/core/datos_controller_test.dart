import 'dart:convert';

import 'package:asistente_app/core/datos/almacen.dart';
import 'package:asistente_app/core/datos/datos_app.dart';
import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/features/fichas/domain/ficha.dart';
import 'package:asistente_app/features/perfil/domain/perfil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final hoy = DateTime(2026, 11, 12, 10);
  late AlmacenEnMemoria almacen;
  late ProviderContainer container;
  DatosController controller() => container.read(datosProvider.notifier);
  DatosApp datos() => container.read(datosProvider);

  setUp(() {
    almacen = AlmacenEnMemoria();
    container = ProviderContainer(
      overrides: [
        almacenProvider.overrideWithValue(almacen),
        relojProvider.overrideWithValue(() => hoy),
      ],
    );
  });
  tearDown(() => container.dispose());

  test('una ficha se guarda con los recordatorios aceptados', () {
    final ficha = controller().agregarFicha(
      tipo: TipoFicha.auto,
      nombre: ' Versa ',
      recordatorios: [
        RecordatorioNuevo(
          titulo: 'Verificación vehicular',
          fecha: DateTime(2027, 1, 15, 8),
          cadaMeses: 6,
        ),
      ],
    );

    expect(ficha.nombre, 'Versa');
    final pendientes = datos().pendientesDeFicha(ficha.id);
    expect(pendientes.single.fecha, DateTime(2027, 1, 15));
    expect(almacen.datos.fichas.single.id, ficha.id);
  });

  test('borrar una ficha se lleva sus recordatorios y deja los demás', () {
    final ficha = controller().agregarFicha(
      tipo: TipoFicha.mascota,
      nombre: 'Rocky',
      recordatorios: [RecordatorioNuevo(titulo: 'Vacunas', fecha: hoy)],
    );
    controller()
      ..agregarRecordatorio(RecordatorioNuevo(titulo: 'Tarjeta', fecha: hoy))
      ..borrarFicha(ficha.id);

    expect(datos().fichas, isEmpty);
    expect(datos().recordatorios.single.titulo, 'Tarjeta');
  });

  test('cumplir uno repetido lo mueve; uno único queda hecho', () {
    controller()
      ..agregarRecordatorio(
        RecordatorioNuevo(
          titulo: 'Renta',
          fecha: DateTime(2026, 11, 30),
          cadaMeses: 1,
        ),
      )
      ..agregarRecordatorio(
        RecordatorioNuevo(titulo: 'Tarjeta', fecha: DateTime(2026, 11, 20)),
      );
    for (final r in datos().recordatorios) {
      controller().cumplir(r.id);
    }

    expect(datos().pendientes.single.titulo, 'Renta');
    expect(datos().pendientes.single.fecha, DateTime(2026, 12, 30));
  });

  test('un familiar con cumpleaños crea su recordatorio anual', () {
    controller().agregarFamiliar(
      nombre: 'Ana',
      parentesco: 'Pareja',
      cumple: DateTime(1990, 3, 5),
    );
    final recordatorio = datos().pendientes.single;
    expect(recordatorio.titulo, 'Cumpleaños de Ana');
    expect(recordatorio.fecha, DateTime(2027, 3, 5));
    expect(recordatorio.cadaMeses, 12);

    controller().borrarFamiliar(datos().familiares.single.id);
    expect(datos().recordatorios, isEmpty);
  });

  test('los datos sobreviven a cerrar y abrir la app', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final local = AlmacenLocal(prefs);
    final primera = ProviderContainer(
      overrides: [almacenProvider.overrideWithValue(local)],
    );
    primera.read(datosProvider.notifier)
      ..guardarPerfil(
        const Perfil(nombre: 'Alex', avatar: '😎', etapa: EtapaDeVida.pareja),
      )
      ..agregarFamiliar(
        nombre: 'Ana',
        parentesco: 'Pareja',
        cumple: DateTime(1990, 3, 5),
        telefono: '5512345678',
      )
      ..agregarFicha(tipo: TipoFicha.renta, nombre: 'Depto 3B');
    await Future<void>.delayed(Duration.zero);
    primera.dispose();

    final segunda = ProviderContainer(
      overrides: [almacenProvider.overrideWithValue(AlmacenLocal(prefs))],
    );
    addTearDown(segunda.dispose);
    final leidos = segunda.read(datosProvider);
    expect(leidos.perfil!.nombre, 'Alex');
    expect(leidos.familiares.single.telefono, '5512345678');
    expect(leidos.fichas.single.tipo, TipoFicha.renta);
    expect(leidos.recordatorios.single.familiarId, leidos.familiares.single.id);
  });

  test('si lo guardado está dañado, la app arranca vacía', () async {
    SharedPreferences.setMockInitialValues({AlmacenLocal.clave: '{roto'});
    final prefs = await SharedPreferences.getInstance();
    expect(AlmacenLocal(prefs).leer().perfil, isNull);
    expect(prefs.getString('${AlmacenLocal.clave}_danado'), '{roto');
    expect(jsonEncode(const DatosApp().toJson()), contains('fichas'));
  });
}
