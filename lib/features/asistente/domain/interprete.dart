import 'package:asistente_app/core/fechas.dart';
import 'package:asistente_app/features/asistente/domain/orden.dart';
import 'package:asistente_app/features/fichas/domain/ficha.dart';

/// Convierte una frase en una [Orden] con reglas sencillas, sin internet.
///
/// Está pensado para cambiarse después por un intérprete con inteligencia
/// artificial que devuelva las mismas órdenes.
Orden interpretar(String frase, DateTime hoy) {
  final texto = frase.trim();
  final simple = _sinAcentos(texto.toLowerCase());

  final ficha = _fichaNueva(simple);
  if (ficha != null) return ficha;

  final recordatorio = RegExp(
    r'^(?:oye\s+)?(?:recuerdame|recordarme|recordar|no olvidar|no me dejes olvidar|avisame)\s+(?:que\s+)?(?:de\s+)?(.+)$',
  ).firstMatch(simple);
  if (recordatorio != null) {
    final (hora, sinHora) = _extraerHora(
      texto.substring(texto.length - recordatorio.group(1)!.length),
    );
    var (fecha, resto) = _extraerFecha(sinHora, hoy);
    // "A las 8" sin día: hoy si aún no pasa, si no mañana.
    if (fecha == null && hora != null) {
      final base = soloDia(hoy);
      final yaPaso = base.add(Duration(minutes: hora)).isBefore(hoy);
      fecha = yaPaso ? base.add(const Duration(days: 1)) : base;
    }
    return CrearRecordatorio(_mayuscula(resto), fecha: fecha, hora: hora);
  }

  final conNota = RegExp(r'^(?:nota|anota|apunta)\s*:?\s+(.+)$')
      .firstMatch(simple);
  final cuerpo = conNota == null
      ? texto
      : texto.substring(texto.length - conNota.group(1)!.length);
  return CrearNota(
    _mayuscula(cuerpo),
    _categoria(_sinAcentos(cuerpo.toLowerCase())),
  );
}

const _verbosDeCompra = [
  'compre',
  'adquiri',
  'tengo',
  'adopte',
  'rente',
  'me dieron',
  'me regalaron',
  'registra',
  'registrar',
  'agrega',
  'agregar',
  'nuevo',
  'nueva',
];

const Map<TipoFicha, List<String>> _palabrasFicha = {
  TipoFicha.auto: ['auto', 'carro', 'coche', 'camioneta', 'moto', 'vehiculo'],
  TipoFicha.mascota: [
    'perro',
    'perrito',
    'gato',
    'gatito',
    'mascota',
    'cachorro',
  ],
  TipoFicha.renta: [
    'departamento en renta',
    'depa en renta',
    'inquilino',
    'renta',
  ],
  TipoFicha.casa: ['casa', 'departamento', 'depa'],
};

CrearFicha? _fichaNueva(String simple) {
  final verbos = _verbosDeCompra.join('|');
  if (!RegExp('\\b(?:$verbos)\\b').hasMatch(simple)) return null;
  for (final MapEntry(key: tipo, value: palabras) in _palabrasFicha.entries) {
    for (final palabra in palabras) {
      if (RegExp('\\b$palabra\\b').hasMatch(simple)) {
        final nombre = RegExp(r'(?:se llama|llamado|llamada|de nombre)\s+(\w+)')
            .firstMatch(simple)
            ?.group(1);
        return CrearFicha(
          tipo,
          nombre: nombre == null ? '' : _mayuscula(nombre),
        );
      }
    }
  }
  return null;
}

const _diasSemana = {
  'lunes': 1,
  'martes': 2,
  'miercoles': 3,
  'jueves': 4,
  'viernes': 5,
  'sabado': 6,
  'domingo': 7,
};

const _mesesNombre = {
  'enero': 1,
  'febrero': 2,
  'marzo': 3,
  'abril': 4,
  'mayo': 5,
  'junio': 6,
  'julio': 7,
  'agosto': 8,
  'septiembre': 9,
  'octubre': 10,
  'noviembre': 11,
  'diciembre': 12,
};

/// Busca una fecha en la frase y la devuelve junto con el texto sin ella.
(DateTime?, String) _extraerFecha(String texto, DateTime hoy) {
  final base = soloDia(hoy);
  final simple = _sinAcentos(texto.toLowerCase());
  final reglas = <(RegExp, DateTime? Function(Match))>[
    (RegExp(r'\bpasado manana\b'), (_) => base.add(const Duration(days: 2))),
    (RegExp(r'\bmanana\b'), (_) => base.add(const Duration(days: 1))),
    (RegExp(r'\bhoy\b'), (_) => base),
    (
      RegExp(r'\ben (\d+) dias?\b'),
      (m) => base.add(Duration(days: int.parse(m.group(1)!))),
    ),
    (
      RegExp(r'\ben (\d+) semanas?\b'),
      (m) => base.add(Duration(days: 7 * int.parse(m.group(1)!))),
    ),
    (
      RegExp(r'\ben (\d+) mes(?:es)?\b'),
      (m) => sumarMeses(base, int.parse(m.group(1)!)),
    ),
    (
      RegExp(r'\bla (?:proxima|otra) semana\b'),
      (_) => base.add(const Duration(days: 7)),
    ),
    (
      RegExp(r'\b(?:el )?(\d{1,2}) de (\w+)\b'),
      (m) {
        final mes = _mesesNombre[m.group(2)];
        if (mes == null) return null;
        var fecha = DateTime(base.year, mes, int.parse(m.group(1)!));
        if (fecha.isBefore(base)) {
          fecha = DateTime(base.year + 1, mes, fecha.day);
        }
        return fecha;
      },
    ),
    (
      RegExp(
        r'\b(?:el )?(?:proximo )?(lunes|martes|miercoles|jueves|viernes|sabado|domingo)\b',
      ),
      (m) {
        final objetivo = _diasSemana[m.group(1)]!;
        var dias = (objetivo - base.weekday) % 7;
        if (dias == 0) dias = 7;
        return base.add(Duration(days: dias));
      },
    ),
  ];
  for (final (patron, calcular) in reglas) {
    final m = patron.firstMatch(simple);
    if (m == null) continue;
    final fecha = calcular(m);
    if (fecha == null) continue;
    // Las posiciones coinciden porque quitar acentos no cambia la longitud.
    final resto = (texto.substring(0, m.start) + texto.substring(m.end))
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return (fecha, resto);
  }
  return (null, texto.trim());
}

/// Busca "a las 10", "a las 5 de la tarde" o "a las 17:30".
(int?, String) _extraerHora(String texto) {
  final simple = _sinAcentos(texto.toLowerCase());
  final m = RegExp(
    r'\ba (?:la|las) (\d{1,2})(?::(\d{2}))?(?: ?(am|pm|de la manana|de la tarde|de la noche))?\b',
  ).firstMatch(simple);
  if (m == null) return (null, texto);
  var horas = int.parse(m.group(1)!);
  final minutos = int.parse(m.group(2) ?? '0');
  final parte = m.group(3);
  final tarde =
      parte == 'pm' || parte == 'de la tarde' || parte == 'de la noche';
  if (tarde && horas < 12) horas += 12;
  if ((parte == 'am' || parte == 'de la manana') && horas == 12) horas = 0;
  if (horas > 23 || minutos > 59) return (null, texto);
  final resto = (texto.substring(0, m.start) + texto.substring(m.end))
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return (horas * 60 + minutos, resto);
}

const _categoriasPorPalabra = {
  'Rentas': ['inquilino', 'renta', 'depa', 'departamento', 'contrato'],
  'Trabajo': [
    'trabajo',
    'oficina',
    'jefe',
    'junta',
    'cliente',
    'proyecto',
    'reunion',
  ],
  'Compras': ['comprar', 'compra', 'super', 'mandado', 'tienda'],
  'Casa': ['casa', 'plomero', 'luz', 'agua', 'gas', 'limpieza', 'jardin'],
  'Ideas': ['idea', 'se me ocurrio', 'podria'],
};

String _categoria(String simple) {
  for (final MapEntry(key: categoria, value: palabras)
      in _categoriasPorPalabra.entries) {
    if (palabras.any((p) => RegExp('\\b$p').hasMatch(simple))) return categoria;
  }
  return 'Personal';
}

String _sinAcentos(String s) => s
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ü', 'u')
    .replaceAll('ñ', 'n');

String _mayuscula(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
