# Asistente de vida cotidiana

App móvil (Android primero, iOS después) que ayuda a recordar lo importante:
fichas de auto, casa, mascota y familiares, recordatorios, y un entorno
compartido entre dos cuentas para repartir responsabilidades y pagos.

## Tecnología

- Flutter (Dart) con estructura por funcionalidad: `lib/features/<función>/{domain,presentation}`.
- Riverpod para el estado y go_router para la navegación.
- Los datos se guardan solo en el celular (`shared_preferences`), sin cuentas ni servidor.
- Reglas de análisis estrictas con `very_good_analysis`.

## Cómo correrla

```bash
flutter pub get
flutter run          # en un emulador o celular Android conectado
flutter test         # pruebas
flutter analyze      # revisión de código
```

## Cómo se arma el APK

Cada cambio en `main` lo compila GitHub Actions y lo publica en la versión
`ultima` del repositorio (sección Releases) como `asistente.apk`.

## Estado

- [x] Bienvenida paso a paso (nombre, avatar, etapa de vida)
- [x] Fichas con plantillas que proponen recordatorios (auto, casa, mascota, departamento en renta)
- [x] Familiares con cumpleaños y teléfono
- [x] Recordatorios agrupados por cercanía, repetidos o de una vez
- [ ] Notificaciones en el celular
- [ ] Cifrado y respaldo de los datos
- [ ] Entorno compartido (requiere servidor)
