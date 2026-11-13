import 'dart:convert';

import 'package:asistente_app/core/datos/datos_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dónde se guardan los datos. Hoy es el almacenamiento privado del celular.
abstract interface class Almacen {
  DatosApp leer();
  Future<void> guardar(DatosApp datos);
}

class AlmacenLocal implements Almacen {
  AlmacenLocal(this._prefs);

  static const clave = 'datos_v1';

  final SharedPreferences _prefs;

  @override
  DatosApp leer() {
    final texto = _prefs.getString(clave);
    if (texto == null) return const DatosApp();
    try {
      return DatosApp.fromJson(jsonDecode(texto) as Map<String, dynamic>);
    } on Object catch (error) {
      // Si el archivo se dañó, se conserva una copia y se empieza de cero.
      debugPrint('No se pudieron leer los datos: $error');
      _guardarCopia(texto);
      return const DatosApp();
    }
  }

  void _guardarCopia(String texto) {
    _prefs.setString('${clave}_danado', texto).ignore();
  }

  @override
  Future<void> guardar(DatosApp datos) =>
      _prefs.setString(clave, jsonEncode(datos.toJson()));
}

/// Almacén que solo vive en memoria; para pruebas.
class AlmacenEnMemoria implements Almacen {
  AlmacenEnMemoria([this.datos = const DatosApp()]);

  DatosApp datos;

  @override
  DatosApp leer() => datos;

  @override
  Future<void> guardar(DatosApp datos) async => this.datos = datos;
}

/// Se reemplaza en `main` con [AlmacenLocal].
final almacenProvider = Provider<Almacen>((ref) => AlmacenEnMemoria());
