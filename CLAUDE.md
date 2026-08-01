# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

`meca_lab` is past the initial scaffold: `lib/main.dart` bootstraps `atomic_design` tokens, `SharedPreferences`, and a `ProviderScope`, then hands off to `lib/app.dart` (`App`), which gates on the initial auth-session check before mounting `MaterialApp.router`. State management is Riverpod 3+ with `riverpod_generator` (`@riverpod`/`@Riverpod(...)` codegen, no hand-written `NotifierProvider`). Routing is `go_router`, with routes declared only for features that actually exist (`/login`, `/dashboard`). Clean Architecture per feature (`domain/data/presentation`) is established and in active use — see "Cómo trabajar en este repo" below and the `meclab-flutter-dashboard-demo` skill for the full convention. `auth` and `dashboard` are complete (all three layers, tests passing); `device_detail`, `alerts`, and `setpoints` don't exist yet.

## Commands

Standard Flutter CLI workflow (run from the repository root):

- Install dependencies: `flutter pub get`
- Run the app: `flutter run` (add `-d <device_id>`; use `flutter devices` to list targets — Android, iOS, Windows, Linux, macOS, and web are all scaffolded)
- Analyze/lint: `flutter analyze` (rules come from `package:flutter_lints/flutter.yaml` via `analysis_options.yaml`)
- Run all tests: `flutter test`
- Run a single test file: `flutter test test/<file>_test.dart`
- Format code: `dart format .`
- Build a release artifact: `flutter build apk` / `flutter build ios` / `flutter build windows` / `flutter build web` etc.

## Architecture notes

- Entry point is `lib/main.dart`; `App` (in `lib/app.dart`) is the root widget passed to `runApp`, wrapped in `ProviderScope`.
- Platform runner directories (`android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/`) are the standard Flutter-generated scaffolding and generally shouldn't need manual edits except for platform configuration (app id, permissions, icons, entitlements).
- Dart SDK constraint: `^3.12.2` (see `pubspec.yaml`).
- `test/` mirrors `lib/` per feature and layer (`domain/`, `data/`, `presentation/`) — see the skill's testing section for conventions and known gotchas (e.g. `StreamNotifier` error tests need `tester.runAsync`, not just `pump`/`pumpAndSettle`).
- A partir de aquí, toda nueva feature debe seguir Clean Architecture por feature (`domain/data/presentation`) — ver la sección "Cómo trabajar en este repo" más abajo. No es opcional ni una sugerencia de estilo.

---

## Contexto del negocio (resumen)

Producto comercial multi-tenant de IoT industrial de MecLab: conecta máquinas industriales (vía un
gateway externo que ya resuelve la comunicación con PLCs) y visualiza sus datos en un dashboard.

- **Equipo:** Juan Camilo Sepúlveda, solo en la parte técnica, con un socio en la parte comercial.
- Contexto completo, decisiones de arquitectura ya tomadas y preguntas abiertas del proyecto:
  ver **`meclab-iot-contexto-proyecto.md`** en la raíz del repo — léelo siempre al empezar una
  sesión nueva. No lo dupliques ni lo contradigas; si una decisión ahí cambia, ese archivo es la
  fuente de verdad y hay que actualizarlo, no crear una segunda fuente.

**Importante — nombres de clientes reales:** el proyecto real tiene un cliente piloto (detallado en
`meclab-iot-contexto-proyecto.md`), pero **esta app (`meca_lab`) es una demo que se muestra a
distintas empresas prospecto**, no solo al cliente piloto. Por eso, **nunca uses el nombre del
cliente piloto real, ni el de ninguna otra empresa real, en código, mock data, copy de UI,
nombres de archivo o assets.** Usa siempre un nombre de cliente/planta ficticio, definido en la
skill `meclab-flutter-dashboard-demo`.

## Fase actual del proyecto

Estamos en la fase de **demo visual del dashboard**, construida en Flutter (responsive, web +
móvil), **sin conexión a backend real**. Usa datos simulados (mock).

- La skill `meclab-flutter-dashboard-demo` (en `.claude/skills/`) tiene el detalle completo:
  pantallas, modelo de datos mock, sistema de diseño traducido a Flutter, y arquitectura de
  carpetas/estado. Consúltala para cualquier trabajo sobre el dashboard.
- El backend (MQTT/EMQX, Postgres+TimescaleDB, autenticación Keycloak/Supabase) **ya tiene
  decisiones de arquitectura tomadas** en `meclab-iot-contexto-proyecto.md`, pero **no se
  implementa todavía**. Si en algún momento se pide conectar la demo a un backend real, es un
  cambio de fase — confírmalo explícitamente con Juan Camilo antes de empezar, no lo asumas como
  continuación natural de una tarea de UI.
- No construyas control remoto de actuadores ni botones de start/stop funcionales sobre
  maquinaria — está fuera de alcance hasta que exista diseño de seguridad funcional (enclavamientos,
  confirmación explícita, timeouts, revisión de un ingeniero de seguridad funcional).

## Cómo trabajar en este repo (proceso, no solo estilo)

- **Avanza paso a paso.** No generes de una vez toda la estructura de carpetas de una feature, y
  mucho menos de varias features. Construye una capa, escribe su test, confírmalo, y recién ahí
  sigue con la siguiente. El detalle completo del ciclo (domain → data → presentation, con tests
  en cada capa) está en la skill `meclab-flutter-dashboard-demo`.
- **Clean Architecture por feature es obligatorio** en cualquier código de Flutter de este
  proyecto: cada feature tiene `domain/`, `data/` y `presentation/` propios, con la regla de
  dependencia `presentation → domain ← data`. No mezclar lógica de negocio en widgets ni acceder al
  mock directamente desde `presentation`.
- **Tests no son opcionales ni al final.** Se escriben a medida que se construye cada capa
  (`flutter test`), no como un paso final de limpieza.
- **No reinventes componentes de UI.** El repo `atomic_design`
  (github.com/Maullin1996/atomic_design) ya define la base de componentes (átomos/moléculas/
  organismos/templates) para los proyectos de Juan Camilo. Revísalo antes de crear botones,
  cards, inputs, etc. nuevos — encaja los widgets del dashboard ahí en vez de duplicar el sistema.

## Plugins instalados en este entorno

Están disponibles globalmente `code-review`, `Dart and Flutter`, `firebase` (+ MCP),
`frontend-design`, `skill-creator`, y los MCPs `claude-in-chrome` y `Notion`. Guía de cuándo usar
cada uno para el trabajo de este proyecto (detalle completo en la skill del dashboard):

- `Dart and Flutter` → apóyate en él para cualquier comando/convención de Dart o Flutter.
- `code-review` → úsalo al cerrar cada capa o feature, antes de seguir con la siguiente.
- `frontend-design` → para decisiones de UI no cubiertas por los tokens ya definidos.
- `skill-creator` → solo si hace falta crear/ajustar una skill, no para el trabajo día a día.
- `firebase` (plugin + MCP) → **no usarlo sin confirmar explícitamente.** El proyecto ya decidió
  Keycloak o Supabase Auth para el backend real; no asumas Firebase solo porque está instalado.
- `claude-in-chrome`, Notion MCP → no aplican al trabajo de Flutter en sí; no los uses a menos que
  se pida algo que realmente los necesite.

## Sistema de diseño

`DESIGN_SYSTEM.md` (en la raíz del repo) es la fuente de verdad visual para cualquier frontend de
este proyecto, no solo el dashboard Flutter. Está basado en la landing MecaLab360 (estética GitHub
Primer oscuro, naranja de marca `#F47820`, Inter + JetBrains Mono). Si se agrega una landing, panel
de administración u otro frontend más adelante, reutiliza los mismos tokens — no crear paletas o
sistemas de estilo distintos por proyecto sin que Juan Camilo lo pida explícitamente.

En el dashboard Flutter, estos tokens ya están resueltos y wireados dentro del paquete
`atomic_design` (JSON de configuración + `AppColors.of(context)` / `AppTokens.of(context)`) — no
se redefinen en un `ThemeData` propio ni en otro lugar. Detalle completo en la skill
`meclab-flutter-dashboard-demo`.

## Cómo prefiere trabajar Juan Camilo

- **Comunicación en español**, explicaciones prácticas y de fundamentos primero, antes de saltar a
  código o documentos extensos.
- **Prefiere asesoría crítica y honesta, no validación automática.** Si algo parece
  sobre-ingeniería, un supuesto débil, o un riesgo (ej. una dependencia frágil, un patrón que no
  escalará, una decisión que contradice lo ya acordado en `meclab-iot-contexto-proyecto.md`),
  dilo explícitamente aunque no sea lo que se quiere escuchar — no lo suavices hasta desaparecerlo.
- Tiene formación sólida en robótica industrial, automatización (Yaskawa Motoman, PLCs), e IoT
  agrícola con LoRa — el lado OT/industrial lo entiende bien y no necesita explicación básica. El
  reto suele estar más del lado de arquitectura de software y decisiones de producto, así que ahí
  sí vale la pena explicar el "por qué" de una recomendación, no solo el "qué".
- Evitar generalizar infraestructura antes de tener evidencia de que hace falta (billing,
  onboarding self-service, admin multi-tenant sofisticado) — el proyecto ya tomó esa decisión
  explícitamente como principio guía.

## Al terminar una tarea

Si el cambio afecta una decisión de arquitectura, alcance, o algo que debería quedar registrado
para la próxima sesión, sugiere actualizar `meclab-iot-contexto-proyecto.md` en vez de dejar esa
información solo en la conversación.
