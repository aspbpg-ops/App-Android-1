import 'package:asistente_app/app/app.dart';
import 'package:asistente_app/core/datos/almacen.dart';
import 'package:asistente_app/core/datos/datos_app.dart';
import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/features/asistente/domain/dictado.dart';
import 'package:asistente_app/features/avisos/data/notificador.dart';
import 'package:asistente_app/features/perfil/domain/perfil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Micrófono de mentira: "dice" la frase que se le dé.
class _DictadoFalso implements Dictado {
  String frase = '';

  @override
  Future<bool> preparar() async => true;

  @override
  Future<void> escuchar(
    void Function(String texto, {required bool alFinal}) alTexto,
  ) async => alTexto(frase, alFinal: true);

  @override
  Future<void> detener() async {}
}

void main() {
  final hoy = DateTime(2026, 11, 12, 10);
  const conPerfil = DatosApp(
    perfil: Perfil(nombre: 'Alex', avatar: '😎', etapa: EtapaDeVida.pareja),
  );
  late _DictadoFalso dictado;

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
    dictado = _DictadoFalso();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          almacenProvider.overrideWithValue(almacen),
          relojProvider.overrideWithValue(() => hoy),
          dictadoProvider.overrideWithValue(dictado),
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

    expect(find.text('Buenos días, Alex'), findsOneWidget);
    expect(find.text('Todo al día.'), findsOneWidget);
    expect(almacen.datos.perfil!.etapa, EtapaDeVida.pareja);
  });

  testWidgets('con perfil guardado abre directo en el inicio', (tester) async {
    await abrir(tester, conPerfil);
    expect(find.text('Buenos días, Alex'), findsOneWidget);
  });

  testWidgets('"Compré un auto" abre la ficha del auto paso a paso', (
    tester,
  ) async {
    final almacen = await abrir(tester, conPerfil);

    await tocar(tester, find.byKey(const Key('barra-asistente')));
    await tester.enterText(
      find.byKey(const Key('campo-asistente')),
      'Hoy compré un auto nuevo',
    );
    await tester.pump();
    expect(find.text('Entendí → Nueva ficha: 🚗 Auto'), findsOneWidget);
    await tocar(tester, find.byKey(const Key('boton-continuar-asistente')));

    // Ya sabe que es un auto: empieza en el nombre.
    expect(find.text('Nueva ficha · Paso 2 de 3'), findsOneWidget);
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

    final titulos = almacen.datos.recordatorios.map((r) => r.titulo);
    expect(almacen.datos.fichas.single.nombre, 'Versa gris');
    expect(titulos, hasLength(4));
    expect(titulos, isNot(contains('Renovar seguro del auto')));

    // La llanta es mensual: es lo próximo y aparece destacada.
    expect(
      find.descendant(
        of: find.byKey(const Key('destacado')),
        matching: find.text('Calibrar llantas y revisar refacción'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('dictar un recordatorio con día y hora', (tester) async {
    final almacen = await abrir(tester, conPerfil);
    dictado.frase = 'Recuérdame mañana a las 10 llamar a mamá';

    await tocar(tester, find.byKey(const Key('barra-microfono')));
    expect(
      find.text('Entendí → Recordatorio: Llamar a mamá · Mañana a las 10:00'),
      findsOneWidget,
    );
    await tocar(tester, find.byKey(const Key('boton-continuar-asistente')));
    await tocar(tester, find.byKey(const Key('boton-guardar')));

    final r = almacen.datos.recordatorios.single;
    expect(r.titulo, 'Llamar a mamá');
    expect(r.fecha, DateTime(2026, 11, 13));
    expect(r.hora, 600);
    expect(find.text('Llamar a mamá'), findsOneWidget);
  });

  testWidgets('una frase suelta se guarda como nota clasificada', (
    tester,
  ) async {
    final almacen = await abrir(tester, conPerfil);
    await tocar(tester, find.byKey(const Key('barra-asistente')));
    await tester.enterText(
      find.byKey(const Key('campo-asistente')),
      'El inquilino del 3B reportó una fuga',
    );
    await tester.pump();
    await tocar(tester, find.byKey(const Key('boton-continuar-asistente')));
    await tocar(tester, find.byKey(const Key('boton-guardar-nota')));

    expect(almacen.datos.notas.single.categoria, 'Rentas');

    await tocar(tester, find.text('Mi vida'));
    expect(find.text('1 pendientes'), findsOneWidget);
    await tocar(tester, find.byKey(const Key('mi-vida-notas')));
    expect(find.text('El inquilino del 3B reportó una fuga'), findsOneWidget);
    await tocar(tester, find.byType(Checkbox));
    expect(find.text('Terminadas (1)'), findsOneWidget);
    expect(almacen.datos.notas.single.pendiente, isFalse);
  });

  testWidgets('marcar como hecho se puede deshacer', (tester) async {
    final almacen = await abrir(tester, conPerfil);
    await tocar(tester, find.byKey(const Key('barra-asistente')));
    await tester.enterText(
      find.byKey(const Key('campo-asistente')),
      'recuérdame mañana pagar la tarjeta',
    );
    await tester.pump();
    await tocar(tester, find.byKey(const Key('boton-continuar-asistente')));
    await tocar(tester, find.byKey(const Key('boton-guardar')));

    await tocar(tester, find.byTooltip('Marcar como hecho'));
    expect(find.text('Todo al día.'), findsOneWidget);
    expect(almacen.datos.recordatorios.single.hecho, isTrue);

    await tocar(tester, find.text('Deshacer'));
    expect(almacen.datos.recordatorios.single.hecho, isFalse);
  });

  testWidgets('el calendario muestra lo pendiente del día elegido', (
    tester,
  ) async {
    await abrir(tester, conPerfil);
    await tocar(tester, find.byKey(const Key('barra-asistente')));
    await tester.enterText(
      find.byKey(const Key('campo-asistente')),
      'recuérdame el 20 de noviembre ir al dentista',
    );
    await tester.pump();
    await tocar(tester, find.byKey(const Key('boton-continuar-asistente')));
    await tocar(tester, find.byKey(const Key('boton-guardar')));

    await tocar(tester, find.text('Calendario').last);
    expect(find.text('Noviembre de 2026'), findsOneWidget);
    expect(find.text('Nada para este día.'), findsOneWidget);
    await tocar(tester, find.byKey(const Key('dia-20')));
    expect(find.text('Ir al dentista'), findsOneWidget);
  });

  testWidgets('las notificaciones se reprograman al cambiar los datos', (
    tester,
  ) async {
    final notificador = NotificadorNulo();
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          almacenProvider.overrideWithValue(AlmacenEnMemoria(conPerfil)),
          relojProvider.overrideWithValue(() => hoy),
          notificadorProvider.overrideWithValue(notificador),
        ],
        child: const AsistenteApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(notificador.programados, isEmpty);

    await tocar(tester, find.byKey(const Key('barra-asistente')));
    await tester.enterText(
      find.byKey(const Key('campo-asistente')),
      'recuérdame mañana a las 10 llamar a mamá',
    );
    await tester.pump();
    await tocar(tester, find.byKey(const Key('boton-continuar-asistente')));
    await tocar(tester, find.byKey(const Key('boton-guardar')));

    final aviso = notificador.programados.singleWhere(
      (a) => a.titulo == 'Llamar a mamá',
    );
    expect(aviso.momento, DateTime(2026, 11, 13, 10));
    // El cierre de hoy ya menciona lo de mañana.
    expect(notificador.programados.first.cuerpo, 'Mañana: Llamar a mamá.');
  });

  testWidgets('borrar todo regresa al onboarding', (tester) async {
    final almacen = await abrir(tester, conPerfil);
    await tocar(tester, find.byKey(const Key('acceso-perfil')));
    await tester.scrollUntilVisible(
      find.byKey(const Key('boton-borrar-todo')),
      300,
    );
    await tocar(tester, find.byKey(const Key('boton-borrar-todo')));
    await tocar(tester, find.text('Borrar'));

    expect(find.text('Paso 1 de 4'), findsOneWidget);
    expect(almacen.datos.perfil, isNull);
  });
}
