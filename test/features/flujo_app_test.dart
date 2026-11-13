import 'package:asistente_app/app/app.dart';
import 'package:asistente_app/core/datos/almacen.dart';
import 'package:asistente_app/core/datos/datos_app.dart';
import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/features/perfil/domain/perfil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final hoy = DateTime(2026, 11, 12, 10);
  const conPerfil = DatosApp(
    perfil: Perfil(nombre: 'Alex', avatar: '😎', etapa: EtapaDeVida.pareja),
  );

  Future<AlmacenEnMemoria> abrir(
    WidgetTester tester, [
    DatosApp datos = const DatosApp(),
  ]) async {
    // Tamaño de un celular común, para que las listas quepan completas.
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final almacen = AlmacenEnMemoria(datos);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          almacenProvider.overrideWithValue(almacen),
          relojProvider.overrideWithValue(() => hoy),
        ],
        child: const AsistenteApp(),
      ),
    );
    await tester.pumpAndSettle();
    return almacen;
  }

  Future<void> tocar(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('el onboarding crea el perfil y abre el inicio', (tester) async {
    final almacen = await abrir(tester);
    const continuar = Key('boton-continuar');

    expect(find.text('Paso 1 de 4'), findsOneWidget);
    await tocar(tester, find.byKey(continuar));

    expect(tester.widget<FilledButton>(find.byKey(continuar)).enabled, isFalse);
    await tester.enterText(find.byKey(const Key('campo-nombre')), 'Alex');
    await tester.pump();
    await tocar(tester, find.byKey(continuar));
    await tocar(tester, find.byKey(const Key('avatar-😎')));
    await tocar(tester, find.byKey(continuar));
    await tocar(tester, find.byKey(const Key('etapa-pareja')));
    await tocar(tester, find.byKey(continuar));

    expect(find.text('Hola, Alex'), findsOneWidget);
    expect(find.text('Nada pendiente'), findsOneWidget);
    expect(almacen.datos.perfil!.etapa, EtapaDeVida.pareja);
  });

  testWidgets('con perfil guardado abre directo en el inicio', (tester) async {
    await abrir(tester, conPerfil);
    expect(find.text('Hola, Alex'), findsOneWidget);
  });

  testWidgets('crear una ficha de auto propone sus recordatorios', (
    tester,
  ) async {
    final almacen = await abrir(tester, conPerfil);

    await tocar(tester, find.text('Fichas'));
    await tocar(tester, find.byKey(const Key('boton-agregar')));
    await tocar(tester, find.byKey(const Key('tipo-auto')));
    await tester.enterText(
      find.byKey(const Key('campo-nombre-ficha')),
      'Versa gris',
    );
    await tester.pump();
    await tocar(tester, find.byKey(const Key('boton-continuar-ficha')));

    expect(find.text('Verificación vehicular'), findsOneWidget);
    // Se quita una sugerencia que no aplica.
    await tocar(tester, find.text('Renovar seguro del auto'));
    await tocar(tester, find.byKey(const Key('boton-continuar-ficha')));

    expect(find.text('Versa gris'), findsOneWidget);
    final titulos = almacen.datos.recordatorios.map((r) => r.titulo);
    expect(titulos, hasLength(4));
    expect(titulos, isNot(contains('Renovar seguro del auto')));

    // La llanta es mensual: aparece en "Hoy" dentro de este mes.
    await tocar(tester, find.text('Hoy'));
    expect(find.text('Este mes (1)'), findsOneWidget);
    expect(find.text('Calibrar llantas y revisar refacción'), findsOneWidget);
  });

  testWidgets('marcar como hecho quita el recordatorio único', (tester) async {
    final almacen = await abrir(tester, conPerfil);

    await tocar(tester, find.byKey(const Key('boton-agregar')));
    await tester.enterText(find.byKey(const Key('campo-titulo')), 'Tarjeta');
    await tocar(tester, find.byKey(const Key('campo-fecha')));
    await tocar(tester, find.text('ACEPTAR'));
    await tocar(tester, find.byKey(const Key('boton-guardar')));

    expect(find.text('Esta semana (1)'), findsOneWidget);
    await tocar(tester, find.byTooltip('Marcar como hecho'));
    expect(find.text('Nada pendiente'), findsOneWidget);
    expect(almacen.datos.recordatorios.single.hecho, isTrue);
  });

  testWidgets('borrar todo regresa al onboarding', (tester) async {
    final almacen = await abrir(tester, conPerfil);
    await tocar(tester, find.byKey(const Key('boton-perfil')));
    await tocar(tester, find.byKey(const Key('boton-borrar-todo')));
    await tocar(tester, find.text('Borrar'));

    expect(find.text('Paso 1 de 4'), findsOneWidget);
    expect(almacen.datos.perfil, isNull);
  });

  testWidgets('una nota se guarda con su categoría y se filtra', (
    tester,
  ) async {
    final almacen = await abrir(tester, conPerfil);
    await tocar(tester, find.text('Notas'));
    expect(find.text('Sin notas'), findsOneWidget);

    await tocar(tester, find.byKey(const Key('boton-agregar')));
    await tester.enterText(
      find.byKey(const Key('campo-nota')),
      'Llamar al plomero del 3B',
    );
    await tocar(tester, find.byKey(const Key('categoria-Rentas')));
    await tocar(tester, find.byKey(const Key('boton-guardar-nota')));

    expect(find.text('Llamar al plomero del 3B'), findsOneWidget);
    expect(find.text('Pendientes (1)'), findsOneWidget);
    expect(almacen.datos.notas.single.categoria, 'Rentas');

    await tocar(tester, find.byType(Checkbox));
    expect(find.text('Terminadas (1)'), findsOneWidget);
    expect(almacen.datos.notas.single.pendiente, isFalse);
  });

  testWidgets('el calendario muestra lo pendiente del día elegido', (
    tester,
  ) async {
    await abrir(tester, conPerfil);
    await tocar(tester, find.byKey(const Key('boton-agregar')));
    await tester.enterText(find.byKey(const Key('campo-titulo')), 'Dentista');
    await tocar(tester, find.byKey(const Key('campo-fecha')));
    await tocar(tester, find.text('20'));
    await tocar(tester, find.text('ACEPTAR'));
    await tocar(tester, find.byKey(const Key('boton-guardar')));

    await tocar(tester, find.text('Calendario'));
    expect(find.text('Noviembre de 2026'), findsOneWidget);
    expect(find.text('Nada para este día.'), findsOneWidget);
    await tocar(tester, find.byKey(const Key('dia-20')));
    expect(find.text('Dentista'), findsOneWidget);
  });
}
