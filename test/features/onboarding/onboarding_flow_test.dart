import 'package:asistente_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> continuar(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('boton-continuar')));
    await tester.pumpAndSettle();
  }

  bool botonActivo(WidgetTester tester) => tester
      .widget<FilledButton>(find.byKey(const Key('boton-continuar')))
      .enabled;

  testWidgets('recorre el onboarding y llega al inicio', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AsistenteApp()));
    await tester.pumpAndSettle();

    expect(find.text('Paso 1 de 6'), findsOneWidget);
    await continuar(tester);

    expect(botonActivo(tester), isFalse);
    await tester.enterText(find.byKey(const Key('campo-nombre')), 'Alex');
    await tester.pump();
    expect(botonActivo(tester), isTrue);
    await continuar(tester);

    await tester.tap(find.byKey(const Key('avatar-😎')));
    await tester.pump();
    await continuar(tester);

    await tester.tap(find.byKey(const Key('etapa-pareja')));
    await tester.pump();
    await continuar(tester);

    await tester.enterText(
      find.byKey(const Key('campo-invitado')),
      'pareja@correo.mx',
    );
    await tester.pump();
    await continuar(tester);

    expect(find.text('Terminar'), findsOneWidget);
    expect(botonActivo(tester), isFalse);
    await tester.tap(find.byKey(const Key('check-respaldo')));
    await tester.pump();
    await continuar(tester);

    expect(find.text('Hola, Alex'), findsOneWidget);
    expect(find.text('pareja@correo.mx'), findsOneWidget);
  });

  testWidgets('el botón Atrás regresa al paso anterior', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AsistenteApp()));
    await tester.pumpAndSettle();
    await continuar(tester);
    expect(find.text('Paso 2 de 6'), findsOneWidget);

    await tester.tap(find.byTooltip('Atrás'));
    await tester.pumpAndSettle();
    expect(find.text('Paso 1 de 6'), findsOneWidget);
  });
}
