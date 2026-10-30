import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indica si Firebase quedó inicializado. Mientras no exista
/// `google-services.json`, la app funciona en modo local.
final firebaseReadyProvider = Provider<bool>((ref) => false);

Future<bool> initFirebase() async {
  try {
    await Firebase.initializeApp();
    return true;
  } on Object catch (error) {
    debugPrint('Firebase no configurado todavía: $error');
    return false;
  }
}
