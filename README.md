# meca_lab

Demo visual del dashboard IoT de **MecLab** — Flutter, responsive (web + móvil), sin conexión a
backend real. Se muestra a distintas empresas prospecto para comunicar cómo se vería y se sentiría
usar el dashboard, antes de invertir tiempo en el backend real (MQTT/EMQX, Postgres+TimescaleDB,
Keycloak/Supabase — decisiones ya tomadas para el proyecto real, no implementadas aquí).

Todos los datos vienen de un mock en memoria. No hay control remoto de actuadores ni botones de
start/stop funcionales sobre maquinaria — fuera de alcance hasta que exista diseño de seguridad
funcional.

## Stack

- **Flutter** (Dart SDK `^3.12.2`), responsive para web, Android, iOS, Windows, Linux y macOS.
- **Riverpod 3+** con `riverpod_generator` (`@riverpod`, sin `NotifierProvider` manual).
- **go_router** para navegación declarativa.
- **[atomic_design](https://github.com/Maullin1996/atomic_design)** como sistema de componentes y
  tokens de diseño (`AppColors.of(context)` / `AppTokens.of(context)`) — ver `DESIGN_SYSTEM.md`
  para la fuente visual de verdad (estética GitHub Primer oscuro, naranja de marca `#F47820`,
  Inter + JetBrains Mono).
- Clean Architecture por feature (`domain/data/presentation`), con tests en cada capa.

## Estado actual

| Feature | domain | data | presentation | Estado |
|---|---|---|---|---|
| `auth` (Login) | ✅ | ✅ | ✅ | Completa, tests en verde |
| `dashboard` (general) | ✅ | ✅ | ✅ | Completa, tests en verde |
| `device_detail` | ✅ | — | — | Solo domain (entidades + casos de uso) |
| `alerts` | — | — | — | No iniciada |
| `setpoints` | — | — | — | No iniciada |

Orden de construcción: `auth` → `dashboard` → `device_detail` → `alerts` → `setpoints`. El detalle
completo de las 5 pantallas, el modelo de datos mock (`Tenant → Site → Device → Sensor`) y la
convención de arquitectura vive en la skill `meclab-flutter-dashboard-demo`
(`.claude/skills/meclab-flutter-dashboard-demo/SKILL.md`).

## Empezar

```bash
flutter pub get
flutter run              # agrega -d <device_id>; usa `flutter devices` para listar targets
```

## Comandos

- Analizar/lint: `flutter analyze`
- Tests: `flutter test` (un archivo: `flutter test test/<archivo>_test.dart`)
- Formatear: `dart format .`
- Build release: `flutter build apk` / `flutter build ios` / `flutter build windows` / `flutter build web`

## Estructura

```
lib/
├── main.dart              # bootstrap: atomic_design tokens, SharedPreferences, ProviderScope
├── app.dart                # App: gate de sesión inicial + MaterialApp.router
├── core/                   # router, errores, servicios/providers transversales (ej. LocalStorageService)
├── shared/                 # entidades/repositorio compartidos entre features (Tenant, Site, Device, Sensor)
└── features/
    ├── auth/                # domain/data/presentation
    ├── dashboard/            # domain/data/presentation
    └── device_detail/        # domain (data/presentation aún no existen)
```

`test/` mirrors `lib/` por feature y capa (`domain/`, `data/`, `presentation/`).

## Documentación adicional

- `CLAUDE.md` — instrucciones para trabajar en este repo con Claude Code (proceso, convenciones,
  cómo colabora Juan Camilo).
- `DESIGN_SYSTEM.md` — fuente de verdad visual (tokens, tipografía, colores).
- `.claude/skills/meclab-flutter-dashboard-demo/SKILL.md` — guía completa de la demo: pantallas,
  modelo de datos mock, arquitectura de carpetas/estado, componentes de `atomic_design` a usar por
  pantalla, gotchas de testing conocidos.
- `meclab-iot-contexto-proyecto.md` (referenciado en `CLAUDE.md`) — contexto de negocio y
  decisiones de arquitectura del proyecto real. **Este archivo todavía no existe en el repo** — si
  se necesita ese contexto, hay que crearlo o pedirlo explícitamente antes de asumir su contenido.# meca_lab
