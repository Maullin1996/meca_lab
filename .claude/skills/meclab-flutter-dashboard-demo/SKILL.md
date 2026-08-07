---
name: meclab-flutter-dashboard-demo
description: Construye y modifica la demo del dashboard IoT de MecLab en Flutter (responsive — web y móvil), sin backend real, con datos simulados (mock). Úsala siempre que se mencione "dashboard", "demo", "app de MecLab", "pantalla de sensores/dispositivos", "alertas", "setpoints" o "login" dentro de este proyecto, incluso si no se menciona la palabra "Flutter" explícitamente. Impone un proceso incremental (una capa/feature a la vez, nunca todo el árbol de carpetas de golpe), Clean Architecture por feature (domain/data/presentation) con tests en cada capa, reutilización del sistema de componentes atomic_design ya existente, y qué plugins instalados usar o evitar en cada paso.
---

# MecLab — Dashboard IoT demo en Flutter

## Qué es esto y qué NO es

Demo visual e interactiva, no un producto conectado. Se muestra a distintas empresas prospecto
(no solo al cliente piloto del proyecto real), para comunicar cómo se vería y se sentiría usar el
dashboard, antes de invertir tiempo en el backend real.

- Todos los datos vienen de un mock (in-memory) — nunca de una API real, MQTT o base de datos.
- El login es una simulación — no hay Keycloak/Supabase todavía (esa decisión ya está tomada para
  el backend real en `meclab-iot-contexto-proyecto.md`, pero no se implementa aquí).
- Los "guardados" (ajustar un setpoint, reconocer una alerta) solo modifican el estado local en
  memoria — no persisten entre reinicios de la app.
- **No construyas** control remoto de actuadores ni botones de start/stop funcionales sobre
  maquinaria — fuera de alcance en el proyecto real.
- **Nunca uses el nombre real del cliente piloto del proyecto, ni el de ninguna otra empresa real**,
  en código, mock data, copy de UI o nombres de archivo. Usa un nombre de cliente/planta ficticio.

Si en algún momento se pide conectar esto a una API/MQTT real, es un cambio de fase — confírmalo
explícitamente antes de empezar.

## Antes de escribir código

Lee `meclab-iot-contexto-proyecto.md` (raíz del repo) — contexto de negocio completo. **Si ese
archivo no existe todavía en el repo**, dilo explícitamente en vez de asumir o inventar su
contenido — no hay una fuente de verdad alternativa para esas decisiones.

El paquete **`atomic_design`** (github.com/Maullin1996/atomic_design) ya está instalado y su
`README.md` documenta el sistema completo: setup, formato del JSON de tokens, y el catálogo de
átomos/moléculas/organismos disponibles. **Esa documentación es la fuente de verdad — no la
reinterpretes ni la reinventes,** solo síguela. Puntos clave que ya están resueltos y no hay que
volver a decidir:

- Los tokens de color/tipografía/spacing/radius **ya están definidos** en el JSON de configuración
  (light + dark), coherentes con `DESIGN_SYSTEM.md`. No definas un `ThemeData` paralelo ni
  redefinas colores en otro lugar — todo pasa por `AppColors.of(context)` / `AppTokens.of(context)`.
- El catálogo de componentes (`AppText`, `AppButtons`, `AppCard`, `AppLoginForm`, `AppCardList`,
  `AppGridView`, `AppDrawer`, `AppBottomNavBar`, `AppSnackBar`, `AppDialog`, `AppBottomSheet`,
  `AppStateWidget`, `AppChip`/`AppFilterChip`, etc.) ya existe — úsalo antes de construir un widget
  nuevo. Excepción ya conocida: `AppGridView` no se usa en el dashboard (ver `ResponsiveDeviceGrid`
  en "Qué componente de `atomic_design` usar en cada pantalla" más abajo) — sus breakpoints de
  columnas no encajaban y se compuso el grid directamente, siguiendo la propia regla de este
  documento para organisms que no encajan.

## Setup de `atomic_design` en la app — ya hecho

Ya completado (`lib/main.dart` + `lib/app.dart`), no hay que repetirlo: JSON de tokens en
`assets/config/app_config.json` declarado en `pubspec.yaml`, `AtomicDesignConfig.initializeFromAsset`
antes de `runApp`, `MaterialApp`/`MaterialApp.router` envuelto en `AppThemeProvider` con
`AppThemes.light`/`AppThemes.dark` y `themeMode: ThemeMode.dark` fijo (la demo es solo modo oscuro;
el JSON trae también un tema claro por si algún día se quiere soportar, pero no es parte del
alcance salvo que Juan Camilo lo pida explícitamente).

---

## Cómo avanzar: paso a paso, nunca todo de una vez

- **No crees carpetas vacías por adelantado.** Ni las 5 features de golpe, ni siquiera
  `domain/data/presentation` completas de una feature antes de tener código real en cada una.
  Cada carpeta se crea cuando se llena de algo real.
- **Ciclo obligatorio por capa, dentro de cada feature:**
  1. `domain` (entidades + casos de uso + interfaz de repositorio) → tests → confirmar en verde.
  2. `data` (modelos + implementación mock del repositorio) → tests → confirmar en verde.
  3. `presentation` (estado/controller + widgets, construidos sobre `atomic_design`) → widget
     tests → confirmar en verde.
     No se avanza de capa sin que la anterior tenga tests pasando.

* **Orden entre features:** `auth` (Login) → `dashboard` (general) → `device_detail` →
* `alerts` → `setpoints`. Las primeras cuatro ya están completas — `setpoints` es la siguiente.

- **Al cerrar una feature completa**, pausa y confirma con Juan Camilo antes de arrancar la
  siguiente. No sigas en piloto automático.
- Si una tarea pedida implica crear varias features o capas de golpe, dilo explícitamente y
  propón dividirla en los pasos de arriba.

| Si vas a... | Lee también |
|---|---|
| Diseñar `domain` / decidir si algo va a `shared/` | `reference/architecture.md` |
| Construir `presentation` / elegir un componente de UI | `reference/atomic-design-ui.md` |
| Agregar una ruta nueva | `reference/routing.md` |
| Escribir tests | `reference/testing-gotchas.md` |
| Entender el modelo de datos o el estado de las 5 pantallas | `reference/screens-and-data-model.md` |

---

## Plugins instalados — cuáles usar en cada paso

- **`Dart and Flutter`:** para cualquier comando/convención específica de Dart/Flutter (tests,
  `flutter analyze`, formateo) en vez de improvisar comandos.
- **`code-review`:** al cerrar cada capa o feature, antes de pasar a la siguiente.
- **`frontend-design`:** solo para decisiones de UI que no estén ya resueltas por
  `atomic_design` + `DESIGN_SYSTEM.md` — no para reemplazarlos.
- **`skill-creator`:** solo si hace falta crear/ajustar una skill nueva.
- **`firebase` (plugin + MCP):** **no usar sin confirmar explícitamente.** La decisión de auth ya
  tomada es Keycloak o Supabase, no Firebase.
- **`claude-in-chrome`, Notion MCP:** no aplican a este trabajo de Flutter.

---

## Checklist antes de dar por cerrada una capa o feature

- [ ] ¿Esta capa tiene tests y están en verde?
- [ ] ¿Corriste el plugin `code-review` antes de pasar a la siguiente capa/feature?
- [ ] ¿Revisaste si `atomic_design` ya tiene el componente antes de crear uno nuevo?
- [ ] ¿Los colores/spacing/tipografía vienen de `AppColors.of(context)` / `AppTokens.of(context)`,
      nunca hardcodeados?
- [ ] ¿`presentation` llama casos de uso de `domain`, nunca al repositorio mock directamente?
- [ ] ¿La jerarquía tenant/site/device/sensor está presente, aunque hoy sea trivial?
- [ ] ¿Evitaste crear carpetas de features o capas futuras sin código todavía?
- [ ] ¿Evitaste usar Firebase sin confirmarlo explícitamente?
- [ ] ¿Usaste solo nombres ficticios de cliente/planta, nunca el real?
- [ ] Si creaste o promoviste algo a `lib/shared/` (widgets, domain o presentation/controllers),
      ¿ya hay una segunda feature usándolo de verdad (no "por si acaso")?
- [ ] Si reemplazaste un organism de `atomic_design` por uno propio (ej. `ResponsiveDeviceGrid` en
      vez de `AppGridView`), ¿lo dijiste explícitamente y quedó documentado el motivo en esta skill?
