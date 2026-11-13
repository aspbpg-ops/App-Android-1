/// Versión del formato que guarda esta app.
///
/// Regla: lo ya capturado nunca se pierde. Si cambia el formato, se sube
/// este número y se agrega en [_migraciones] el paso que convierte lo
/// anterior, con su prueba en `test/core/migraciones_test.dart`.
const versionDatos = 1;

typedef _Migracion = Map<String, dynamic> Function(Map<String, dynamic>);

/// Paso para pasar de la versión `n` a la `n + 1`, indexado por `n`.
final Map<int, _Migracion> _migraciones = {
  // Las compilaciones 1 a 4 guardaban sin número de versión (versión 0).
  // Sus campos nuevos (notas, hora, horaResumen) son opcionales, así que
  // solo se marca la versión.
  0: (json) => json,
};

/// Versión de unos datos guardados; 0 si no la indican.
int versionDe(Map<String, dynamic> json) => json['version'] as int? ?? 0;

/// Lleva [json] a la versión actual aplicando los pasos que falten.
Map<String, dynamic> migrar(Map<String, dynamic> json) {
  var actual = Map<String, dynamic>.of(json);
  for (var v = versionDe(json); v < versionDatos; v++) {
    actual = _migraciones[v]!(actual)..['version'] = v + 1;
  }
  return actual;
}
