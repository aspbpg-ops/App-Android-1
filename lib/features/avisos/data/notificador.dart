import 'dart:async';

import 'package:asistente_app/core/datos/datos_controller.dart';
import 'package:asistente_app/features/avisos/domain/plan_avisos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_datos;
import 'package:timezone/timezone.dart' as tz;

/// Programa las notificaciones del celular.
abstract interface class Notificador {
  /// Pide permiso para mostrar notificaciones (Android 13 o más nuevo).
  Future<void> pedirPermiso();

  /// Reemplaza todo lo programado por [avisos].
  Future<void> programar(List<Aviso> avisos);

  /// Muestra una notificación al momento, para comprobar que funcionan.
  Future<void> probar();
}

/// Para pruebas y para cuando no hay notificaciones disponibles.
class NotificadorNulo implements Notificador {
  List<Aviso> programados = const [];

  @override
  Future<void> pedirPermiso() async {}

  @override
  Future<void> programar(List<Aviso> avisos) async => programados = avisos;

  @override
  Future<void> probar() async {}
}

class NotificadorAndroid implements Notificador {
  NotificadorAndroid._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  /// Las programaciones se hacen una tras otra para no mezclarse.
  Future<void> _cola = Future.value();

  static const _detalles = NotificationDetails(
    android: AndroidNotificationDetails(
      'recordatorios',
      'Recordatorios',
      channelDescription: 'Tus recordatorios y el cierre del día',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  static Future<Notificador> crear() async {
    try {
      tz_datos.initializeTimeZones();
      final zona = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zona.identifier));
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      return NotificadorAndroid._(plugin);
    } on Object catch (error) {
      debugPrint('Notificaciones no disponibles: $error');
      return NotificadorNulo();
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> pedirPermiso() async {
    await _android?.requestNotificationsPermission();
  }

  @override
  Future<void> programar(List<Aviso> avisos) => _cola = _cola.then((_) async {
    try {
      await _plugin.cancelAllPendingNotifications();
      for (final (i, aviso) in avisos.indexed) {
        await _plugin.zonedSchedule(
          id: i,
          title: aviso.titulo,
          body: aviso.cuerpo,
          scheduledDate: tz.TZDateTime.from(aviso.momento, tz.local),
          notificationDetails: _detalles,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } on Object catch (error) {
      debugPrint('No se pudieron programar los avisos: $error');
    }
  });

  @override
  Future<void> probar() => _plugin.show(
    id: 9999,
    title: 'Así te voy a avisar',
    body: 'Las notificaciones funcionan.',
    notificationDetails: _detalles,
  );
}

/// Se reemplaza en `main` con [NotificadorAndroid].
final notificadorProvider = Provider<Notificador>((ref) => NotificadorNulo());

/// Mantiene las notificaciones al día con los datos.
final sincronizarAvisosProvider = Provider<void>((ref) {
  final datos = ref.watch(datosProvider);
  final ahora = ref.read(relojProvider)();
  unawaited(
    ref.read(notificadorProvider).programar(planearAvisos(datos, ahora)),
  );
});
