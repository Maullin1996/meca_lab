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
- **Riverpod 3+** con `riverpod_generator` (`@riverpod`, sin `NotifierProvider` manual, incluye
  providers `family` para estado por id, ej. `deviceDetailControllerProvider(deviceId)`).
- **go_router** para navegación declarativa (`/login`, `/dashboard`, `/devices/:id`).
- **[atomic_design](https://github.com/Maullin1996/atomic_design)** como sistema de componentes y
  tokens de diseño (`AppColors.of(context)` / `AppTokens.of(context)`) — ver `DESIGN_SYSTEM.md`
  para la fuente visual de verdad (estética GitHub Primer oscuro, naranja de marca `#F47820`,
  Inter + JetBrains Mono).
- **fl_chart** para los gráficos de historial de sensor (única dependencia de charts del proyecto).
- Clean Architecture por feature (`domain/data/presentation`), con tests en cada capa.

## Estado actual

| Feature | domain | data | presentation | Estado |
|---|---|---|---|---|
| `auth` (Login) | ✅ | ✅ | ✅ | Completa, tests en verde |
| `dashboard` (general) | ✅ | ✅ | ✅ | Completa, tests en verde |
| `device_detail` | ✅ | ✅ | ✅ | Completa, tests en verde |
| `alerts` | — | — | — | No iniciada |
| `setpoints` | — | — | — | No iniciada |

`auth`, `dashboard` y `device_detail` comparten historial de sensor vía `lib/shared/` (entidad,
repositorio, caso de uso, controller y el chart compacto `SensorHistoryChart`) — promovido ahí
cuando `dashboard` necesitó el mismo dato que `device_detail` ya tenía, en vez de duplicarlo.
`device_detail` además tiene su propio chart, `SensorHistoryDetailChart` (ejes, selector de rango
día/semana/mes, tooltip), exclusivo de esa pantalla. `dashboard` reemplazó el grid de
`atomic_design` por uno propio (`ResponsiveDeviceGrid`) porque sus breakpoints de columnas no
escalaban en pantallas anchas. Detalle completo de ambas decisiones en la skill.

Orden de construcción: `auth` → `dashboard` → `device_detail` → `alerts` → `setpoints`. Las
primeras tres ya están completas — `alerts` es la siguiente. El detalle completo de las 5
pantallas, el modelo de datos mock (`Tenant → Site → Device → Sensor`) y la convención de
arquitectura vive en la skill `meclab-flutter-dashboard-demo`
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
├── app.dart                # App: un solo MaterialApp.router; el splash de sesión inicial se pinta
│                            #   vía su `builder`, no con un segundo MaterialApp/Navigator
├── core/                   # router, errores, servicios/providers transversales
├── shared/                 # entidades/repositorios/controllers/widgets compartidos entre features
│   ├── domain/               # Tenant, Site, Device, Sensor, SensorReading, SensorHistoryRange...
│   ├── data/                 # MockDeviceDataSource (fuente única de datos mock) + repositorios
│   ├── presentation/         # controllers compartidos (ej. sensorHistoryControllerProvider)
│   └── widgets/               # DeviceStatusBadge, SensorHistoryChart (compacto)
└── features/
    ├── auth/                 # domain/data/presentation
    ├── dashboard/             # domain/data/presentation — incluye ResponsiveDeviceGrid propio
    └── device_detail/         # domain/data/presentation — incluye SensorHistoryDetailChart propio
```

`test/` mirrors `lib/` por feature y capa (`domain/`, `data/`, `presentation/`), más `test/shared/`
como espejo de `lib/shared/`.

## Documentación adicional

- `CLAUDE.md` — instrucciones para trabajar en este repo con Claude Code (proceso, convenciones,
  cómo colabora Juan Camilo).
- `DESIGN_SYSTEM.md` — fuente de verdad visual (tokens, tipografía, colores) para cualquier
  frontend del proyecto, no solo Flutter.
- `.claude/skills/meclab-flutter-dashboard-demo/SKILL.md` — guía completa de la demo: pantallas,
  modelo de datos mock, arquitectura de carpetas/estado, componentes de `atomic_design` a usar por
  pantalla, gotchas de testing conocidos.
- `meclab-iot-contexto-proyecto.md` (referenciado en `CLAUDE.md`) — contexto de negocio y
  decisiones de arquitectura del proyecto real. **Este archivo todavía no existe en el repo** — si
  se necesita ese contexto, hay que crearlo o pedirlo explícitamente antes de asumir su contenido.
