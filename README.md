# Asistente de vida cotidiana

App móvil (Android primero, iOS después) que ayuda a recordar lo importante:
fichas de auto, casa, mascota y familiares, recordatorios, y un entorno
compartido entre dos cuentas para repartir responsabilidades y pagos.

## Tecnología

- Flutter (Dart) con estructura por funcionalidad: `lib/features/<función>/{domain,data,presentation}`.
- Riverpod para el estado y go_router para la navegación.
- Firebase (Auth, Firestore) como backend, con cifrado de extremo a extremo.
- Reglas de análisis estrictas con `very_good_analysis`.

## Cómo correrla

```bash
flutter pub get
flutter run          # en un emulador o celular Android conectado
flutter test         # pruebas
flutter analyze      # revisión de código
```

Mientras no exista `android/app/google-services.json`, la app arranca en
modo local (sin Firebase).

## Estado

- [x] Estructura del proyecto
- [x] Onboarding paso a paso (nombre, avatar, etapa de vida, invitación, clave de respaldo)
- [x] Pruebas del onboarding
- [ ] Conectar Firebase (falta `google-services.json`)
- [ ] Módulo de cifrado
- [ ] Fichas, familiares, recordatorios, entorno compartido
