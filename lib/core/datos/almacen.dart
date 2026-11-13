import 'dart:convert';

import 'package:asistente_app/core/datos/datos_app.dart';
import 'package:asistente_app/core/datos/migraciones.dart';
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
      final json = jsonDecode(texto) as Map<String, dynamic>;
      final version = versionDe(json);
      if (version < versionDatos) {
        // Antes de convertir, se guarda tal cual por si algo sale mal.
        _guardarCopia('respaldo_v$version', texto);
        final migrado = migrar(json);
        _prefs.setString(clave, jsonEncode(migrado)).ignore();
        return DatosApp.fromJson(migrado);
      }
      return DatosApp.fromJson(json);
    } on Object catch (error) {
      // Si no se puede leer, se conserva el original y se empieza de cero.
      debugPrint('No se pudieron leer los datos: $error');
      _guardarCopia('danado', texto);
      return const DatosApp();
    }
  }

  void _guardarCopia(String sufijo, String texto) {
    _prefs.setString('${clave}_$sufijo', texto).ignore();
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
