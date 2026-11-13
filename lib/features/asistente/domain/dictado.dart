import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Convierte la voz en texto con el reconocimiento que trae Android.
abstract interface class Dictado {
  /// Pide permiso del micrófono la primera vez; `false` si no se puede.
  Future<bool> preparar();

  /// Escucha y llama a [alTexto] con lo que va entendiendo; `alFinal`
  /// indica que la persona dejó de hablar.
  Future<void> escuchar(
    void Function(String texto, {required bool alFinal}) alTexto,
  );

  Future<void> detener();
}

class DictadoAndroid implements Dictado {
  final _voz = SpeechToText();

  @override
  Future<bool> preparar() => _voz.initialize();

  @override
  Future<void> escuchar(
    void Function(String texto, {required bool alFinal}) alTexto,
  ) => _voz.listen(
    // Esta versión del paquete solo acepta el idioma por este parámetro.
    // ignore: deprecated_member_use
    localeId: 'es_MX',
    listenOptions: SpeechListenOptions(listenMode: ListenMode.dictation),
    onResult: (r) => alTexto(r.recognizedWords, alFinal: r.finalResult),
  );

  @override
  Future<void> detener() => _voz.stop();
}

final dictadoProvider = Provider<Dictado>((ref) => DictadoAndroid());
