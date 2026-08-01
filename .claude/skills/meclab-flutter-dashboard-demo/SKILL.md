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
- **Orden entre features:** `auth` (Login) → `dashboard` (general) → `device_detail` →
  `alerts` → `setpoints`. Las primeras tres ya están completas — `alerts` es la siguiente.
- **Al cerrar una feature completa**, pausa y confirma con Juan Camilo antes de arrancar la
  siguiente. No sigas en piloto automático.
- Si una tarea pedida implica crear varias features o capas de golpe, dilo explícitamente y
  propón dividirla en los pasos de arriba.

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

## Arquitectura: Clean Architecture por feature

Cada feature (`auth`, `dashboard`, `device_detail`, `alerts`, `setpoints`) tiene sus propias tres
capas. Regla de dependencia fija: `presentation` → depende de → `domain` ← implementado por ← `data`.

- **`domain/`** (Dart puro, sin imports de Flutter): entidades (`Device`, `Sensor`, `Alert`,
  `Setpoint`, `User`...), interfaces de repositorio (`abstract class DeviceRepository`), casos de
  uso (una clase por acción: `GetDevicesUseCase`, `AcknowledgeAlertUseCase`, `LoginUseCase`...).
- **`data/`**: modelos que mapean a las entidades (con `fromJson`/`toJson`, listos para el backend
  real aunque el mock no los use hoy), `Mock<Nombre>RepositoryImpl` que implementa la interfaz de
  domain con datos falsos (`Future.delayed` simulando latencia).
- **`presentation/`**: pantallas y widgets **construidos sobre los componentes de
  `atomic_design`** (no widgets sueltos reinventando botones/cards/inputs que ya existen ahí), más
  un controller expuesto vía **Riverpod** (`Notifier`/`AsyncNotifier`/`StreamNotifier` anotados con
  `@riverpod`, generados con `riverpod_generator` — no declares `NotifierProvider` a mano) por
  feature, que llama casos de uso de domain — nunca al mock ni al repositorio directamente. Si el
  caso de uso expone un `Stream` (ej. `WatchDevicesUseCase`), el controller lo consume con
  `Stream<Estado> build() async* { ... }` (mapea a `StreamNotifier`, no a `AsyncNotifier`) — los
  widgets siguen viendo `AsyncValue<Estado>` igual. KPIs/filtros derivados de la lista (totales,
  conteos, búsqueda) son getters/métodos sobre el estado del controller, no un caso de uso aparte —
  esa capa de dominio solo se justifica si esa lógica crece en complejidad real.
- Los tokens visuales viven en el JSON de `atomic_design` (`assets/config/app_config.json`) y se
  consumen vía `AppColors.of(context)` / `AppTokens.of(context)` — no hay un `core/theme/` propio
  que redefina esto; ver el paso de configuración más arriba.

**Manejo de estado: Riverpod 3+, con code generation (`riverpod_generator` + `@riverpod`).**
`ProviderScope` envuelve toda la app (por fuera de `AppThemeProvider`) desde `main.dart`. Providers
declarados a mano (`Provider(...)`, `NotifierProvider(...)`) solo para lo mínimo que el propio
setup de Riverpod necesite antes de tener el generador corriendo (ej. el placeholder de
`SharedPreferences`) — todo lo demás va con `@riverpod` sobre clases `Notifier`/`AsyncNotifier`.
Riverpod se usa para dos cosas, y solo esas dos: inyectar dependencias (repositorios, data
sources, servicios de `core/`) y exponer estado de `presentation` a los widgets (`AsyncValue` para
loading/success/error). **Riverpod no reemplaza a `shared_preferences` ni a ningún mecanismo de
persistencia real — solo los conecta.** Riverpod es una dependencia que evoluciona rápido (v3 es
"transición", v4 puede llegar pronto) — antes de escribir cualquier provider, revisa la versión
instalada y su sintaxis vigente en vez de asumir de memoria.

**`lib/core/services/`** es donde van los wrappers de plataforma/paquetes externos que son
transversales a varias features (ej. `LocalStorageService` sobre `shared_preferences`). Una
feature nunca debe llamar `SharedPreferences.getInstance()` directamente en su `data/` — depende
del servicio de `core/` en su lugar, inyectado vía un `Provider` de Riverpod.

**`lib/shared/widgets/`** es para widgets de UI compartidos **entre features** (no infraestructura
— eso es `core/`). Tres niveles de reutilización, de más a menos genérico:
1. **`atomic_design`** — reutilizable en cualquier proyecto de Juan Camilo, no solo este.
2. **`lib/shared/widgets/`** — reutilizable entre features de este proyecto (ejemplos reales: ver
   los dos casos justo abajo).
3. **La propia carpeta `presentation/widgets/` de cada feature** — uso exclusivo de esa feature
   (ej. `login_mobile_view.dart`, que no le sirve a nadie más).

**Regla del segundo consumidor:** un widget nace en el nivel 3 (dentro de su feature). Solo sube a
`lib/shared/widgets/` cuando una **segunda** feature ya lo necesita de verdad — nunca lo subas "por
si acaso" antes de que exista ese segundo caso de uso real. Si además tiene sentido fuera de este
proyecto, es candidata a subir a `atomic_design` en su lugar (con confirmación de Juan Camilo, como
ya se estableció). No crees `lib/shared/widgets/` vacío de antemano — se crea cuando el primer
widget realmente sube ahí.

Dos casos reales ya pasaron por esto (no son hipotéticos, son la referencia a seguir):
- **`DeviceStatusBadge`** nació en `dashboard/presentation/widgets/` (usado por `DeviceCard`) y
  subió a `shared/widgets/` cuando `device_detail` lo necesitó para su header.
- **`SensorHistoryChart`** nació en `device_detail/presentation/widgets/` (como `SensorSparkline`,
  sobre un `CustomPainter` propio) y subió a `shared/widgets/` — ya reescrito sobre `fl_chart` — al
  agregarle mini-gráficos a las cards del dashboard.

**`lib/shared/domain/`** — mismo espíritu que `shared/widgets/`, pero para entidades y contratos de
repositorio que usa más de una feature: `Tenant`, `Site`, `Device`, `Sensor`, más la interfaz
`DeviceRepository` (compartidos desde el principio, por la sección "Modelo de datos mock").
`SensorReading` y `SensorHistoryRepository` empezaron exclusivos de `device_detail` y se
**promovieron** a `shared/domain` cuando `dashboard` los necesitó también (sparklines en las cards)
— ejemplo real de la regla del segundo consumidor operando como debía, no una excepción a ella.
`Alert`, `Setpoint` y `User` siguen siendo exclusivos de su feature — esperan su propio segundo
consumidor real, si llega a pasar.

Los **casos de uso** normalmente viven dentro de la `domain/` de cada feature aunque operen sobre
entidades compartidas, porque encapsulan una regla de negocio específica de esa pantalla (ej.
`WatchDeviceDetailUseCase` combina device + sensores de una forma que dashboard no necesita).
**Excepción:** si un caso de uso es exactamente la misma operación sin ninguna variación de regla
de negocio entre features (ej. `WatchSensorHistoryUseCase` — "dame el historial de este sensor" es
idéntico lo pida quien lo pida), va también en `shared/domain/usecases/` en vez de duplicarse una
vez por feature. La pregunta para decidir: ¿hay alguna lógica propia de la pantalla más allá de
llamar al repositorio? Si no, es compartido.

**`lib/shared/presentation/controllers/`** — mismo criterio que arriba, pero para controllers de
Riverpod: cuando un controller expone exactamente el mismo estado sin lógica propia de una pantalla
(ej. `sensorHistoryControllerProvider`, usado igual por `device_detail` y por las cards de
`dashboard`), vive acá en vez de duplicarse o de que una feature importe el controller interno de
otra (eso sí rompería el aislamiento entre features). No crees esta carpeta de antemano — igual que
`shared/widgets/`, se crea cuando el primer controller realmente cruza esa línea.

**Un repositorio compartido puede ganar métodos nuevos, siempre que sigan devolviendo solo
entidades ya compartidas** (ej. `DeviceRepository.watchDeviceById` sigue devolviendo `Device`, y
`DeviceRepository.getSensorsForDevice` puede devolver `List<Sensor>` porque `Sensor` ya es
compartido — aunque `Device` en sí solo traiga `keySensors`, no la lista completa). Si una
funcionalidad nueva obligaría a que el repositorio compartido devuelva una entidad que hoy es
exclusiva de una sola feature, esa funcionalidad **no** entra al repositorio compartido — se
crea un repositorio propio de esa feature (con su propia entidad en su `domain/`), cuya
implementación en `data/` sí puede depender de la misma fuente de datos compartida. Compartir
la *fuente de datos* en `data` no obliga a compartir la *entidad* en `domain`.

## Qué componente de `atomic_design` usar en cada pantalla

No construyas estos widgets desde cero — el paquete ya los tiene:

| Pantalla | Componentes de `atomic_design` a reutilizar |
|---|---|
| Login | **No uses `AppLoginForm`** — no es responsive para web y el diseño no encaja con lo que se busca aquí. Compón la pantalla a medida con los átomos/moléculas de `atomic_design` (`AppInputText`, `AppButtons`, `AppText`, `AppCard`), con layout propio responsive (ver regla de UI a medida abajo) |
| Dashboard general | `AppSearchBar` (buscador), `AppCard` (KPIs y cada `DeviceCard`), `AppDrawer`/`AppBottomNavBar` según breakpoint, `AppStateWidget` para vacío/error. **No `AppGridView`** para la grilla de dispositivos — ver `ResponsiveDeviceGrid` más abajo. Cada `DeviceCard` grafica un solo sensor a la vez (`SensorHistoryChart` en modo `compact`), con un menú para elegir cuál si el device tiene más de uno — ver "Un solo gráfico por card" más abajo |
| Detalle de dispositivo | `AppCard` por sensor (`SensorDetailCard`), `AppText` para valores, `AppStateWidget` para vacío/error, `SensorHistoryDetailChart` (widget exclusivo de la feature, no `SensorHistoryChart`) con ejes X/Y, selector de rango día/semana/mes y tooltip al pasar el mouse |
| Alertas | `AppCardList` (loading/empty/error/list) para la lista, `AppSnackBar` al reconocer una alerta |
| Setpoints | `AppCard` + `AppButtons`, `AppDialog` o `AppBottomSheet` para confirmar el cambio, `AppSnackBar` para la confirmación final |

**`ResponsiveDeviceGrid` (`dashboard/presentation/widgets/`) reemplaza a `AppGridView` para la
grilla de dispositivos.** `AppGridView` fija sus propios breakpoints de columnas (1/360, 2/600,
3/840, 4 desde 840 en adelante, sin parámetro para configurarlos) y se estanca en 4 columnas sin
importar cuán ancha sea la pantalla — con `DeviceCard` ya liviano (ver el punto siguiente), un
`childAspectRatio` fijo no podía servir a la vez a una card de pantalla grande y a una del borde
angosto del rango de 4 columnas sin dejar espacio vacío en un extremo o apretar demasiado en el
otro. `ResponsiveDeviceGrid` compone el grid directamente con `GridView.builder` (regla de
organisms que no encajan, ver arriba), reutilizando `AppCard`/`AppStateWidget` para los estados de
loading/empty/error en vez de reinventarlos. Breakpoints de columnas (`columnCountForWidth`,
definidos a pedido de Juan Camilo, no son los de `atomic_design`): `<450px→1, 450-889→2, 890-1439→3,
1440-1919→4`, y +1 columna cada ~480px de ahí en adelante — así una pantalla ancha gana columnas en
vez de estirar 4 cards cada vez más anchas. Si se necesita otra grilla similar en una feature
futura, revisa primero si estos breakpoints le sirven antes de inventar un tercer esquema.

**Un solo gráfico por card, no uno por sensor (dashboard).** Un `DeviceCard` con 2 sensores
necesitaría el doble de alto que uno con 1 si se apila un `SensorHistoryChart` por sensor — no
encaja con un grid de celdas de aspect ratio fijo. `DeviceCard` es `StatefulWidget` solo para
recordar qué sensor está graficado: lista **todas** las lecturas actuales como texto (barato, una
línea cada una), pero grafica un único sensor a la vez — el primero por defecto, con un
`PopupMenuButton` (ícono `⋮`, `AppIcons.menu`) para cambiar cuál cuando el device tiene más de uno.

**`device_detail` sí muestra el historial completo de cada sensor** (una sola card grande por
sensor, no una grilla de celdas fijas, así que no tiene el problema de arriba) — pero con un chart
propio, distinto al de dashboard:

**`SensorHistoryDetailChart`** (`device_detail/presentation/widgets/`, exclusivo de la feature —
**no** vive en `shared/widgets/` aunque el nombre se parezca al de `SensorHistoryChart`) agrega lo
que el chart compacto del dashboard no necesita: ejes X (tiempo) e Y (variable + unidad) siempre
visibles, un selector de rango día/semana/mes (mismo patrón de `PopupMenuButton` que el selector de
sensor de `DeviceCard`), y un tooltip al pasar el mouse (`LineTouchData` de `fl_chart`) con el valor
y la fecha/hora del punto. Nada de esto se agregó a `SensorHistoryChart` compartido — se habría
tenido que forzar en las celdas angostas del dashboard, que nunca lo pidieron. Como consecuencia,
`ChartVariant.full` de `SensorHistoryChart` quedó sin uso real (solo `compact` se usa hoy); no se
borró de forma unilateral, queda como decisión a confirmar con Juan Camilo si se limpia.

El historial por rango no sale del buffer "vivo" de 40 lecturas (~160s) que ya usa
`watchSensorHistory` — `SensorHistoryRepository` ganó un método nuevo, `getHistoryForRange(sensorId,
range)` (`Future`, no `Stream`, porque es una lectura puntual, no algo que se re-suscribe), y
`MockDeviceDataSource.generateHistoryForRange` genera una caminata aleatoria sintética por sensor
(24 puntos/hora para día, 7/día para semana, 30/día para mes), determinística por
`(sensorId, range)` (seed fijo) para que no "salte" al cambiar de rango y volver — ejemplo real de
"un repositorio compartido puede ganar métodos nuevos" (ver esa sección más abajo). El caso de uso
que lo llama (`GetSensorHistoryForRangeUseCase`) y el provider (`sensorHistoryForRangeProvider`,
family por `(sensorId, range)`) sí son exclusivos de `device_detail` — solo esa pantalla necesita
esta lectura, así que no subieron a `shared/`.

**Convención de archivos para pantallas con layout distinto en web y mobile:** separa
*orquestación* de *composición visual*, nunca dupliques la lógica completa en dos pantallas
paralelas.
- `<pantalla>_page.dart` — el único que conecta con el controller de Riverpod (estado,
  loading, errores, callbacks hacia casos de uso). No tiene layout propio: según el ancho
  (`LayoutBuilder` o el breakpoint que ya resuelva `atomic_design` — revisa primero si el paquete
  expone un helper de breakpoint actual antes de escribir uno nuevo, para no tener dos sistemas de
  breakpoints distintos en la app) decide entre la vista mobile y la web, pasándoles los datos y
  callbacks ya resueltos por constructor.
- `<pantalla>_mobile_view.dart` y `<pantalla>_web_view.dart` — widgets sin estado ni acceso a
  providers, solo reciben datos/callbacks por parámetro y deciden cómo se ven. Aquí es donde se
  toca un ajuste visual puntual de una plataforma sin poder romper la otra.
Esta convención aplica a toda pantalla del dashboard que lo necesite, no solo a Login.

**Regla general sobre organisms de `atomic_design`:** son un punto de partida, no una obligación
ciega. Si uno no encaja (no es responsive, el diseño no convence, no cubre el caso de uso), no lo
fuerces — compón la pantalla directamente con los átomos/moléculas (`AppInputText`, `AppButtons`,
`AppCard`, `AppText`, etc.), que sí siguen siendo obligatorios porque cargan los tokens. Dilo
explícitamente cuando pase esto, no lo cambies en silencio. Para el layout/UI a medida en esos
casos, apóyate en el plugin `frontend-design` (jerarquía visual, composición, responsive) — los
**valores** de color/tipografía/spacing siguen saliendo de `AppColors.of(context)` /
`AppTokens.of(context)`, nunca hardcodeados, así la pantalla a medida se vea consistente con el
resto de la app.

**Componentes que NO existen todavía en `atomic_design`** (hay que construirlos, no evitarlos):
el control de setpoint (slider/stepper acotado a un rango) sigue pendiente — sigue el mismo
criterio que los charts: usa `AppColors.of(context)` / `AppTokens.of(context)`, nunca valores
hardcodeados, y si tiene uso más allá de este proyecto vale la pena sugerir subirlo a
`atomic_design` en vez de dejarlo suelto en la app (confírmalo con Juan Camilo antes de tocar ese
repo).

Los charts de historial de sensor ya se construyeron, sobre **`fl_chart`** (única dependencia
externa de gráficos del proyecto; no agregues una segunda librería de charts sin confirmar con
Juan Camilo) — hay **dos widgets**, no uno:
- **`SensorHistoryChart`** (`lib/shared/widgets/`) — el compacto que usa dashboard. Variantes
  `ChartVariant.full`/`compact` (`full` sin uso real hoy, ver arriba) y un flag `isLive` que apaga
  el color y desactiva la animación cuando el device está offline.
- **`SensorHistoryDetailChart`** (`device_detail/presentation/widgets/`) — el de la pantalla de
  detalle, con ejes, selector de rango y tooltip (ver "Un solo gráfico por card" más arriba). No
  comparte código con `SensorHistoryChart` más allá de usar la misma librería `fl_chart` — son dos
  composiciones deliberadamente distintas para necesidades distintas.

`device_detail_web_view.dart` tampoco usa un grid de aspect ratio fijo para las cards de sensor —
usa `Wrap` (cada card mide su propio contenido; con `SensorHistoryDetailChart` la altura ya no es
constante como en dashboard, así que ni `ResponsiveDeviceGrid` ni un `GridView` con
`childAspectRatio` fijo le servían).

## Enrutamiento

**`go_router`**, introducido en cuanto hubo más de una pantalla real que navegar (dashboard →
detalle de dispositivo). Antes de eso, el arranque de la app resolvía la pantalla a mano según el
estado de `authController` — eso se reemplaza por rutas + `redirect` de `go_router` basado en ese
mismo estado (no se duplica la lógica de sesión, solo se conecta a rutas). Rutas nuevas se agregan
a medida que la feature correspondiente exista de verdad — no declares rutas para pantallas que
todavía no se construyeron.

Rutas actuales: `/login`, `/dashboard`, `/devices/:id` (primera ruta con path param del proyecto —
`AppRoutes.deviceDetailPath(id)` arma el string, `state.pathParameters['id']!` lo lee en el
`builder`). Desde el dashboard se navega con `context.push(...)`, no `Navigator.push` — en widget
tests que ejercen ese flujo hace falta un `GoRouter` real de verdad en el árbol (ver gotcha de
testing más abajo), un `MaterialApp(home: ...)` sin router no alcanza.

## Testing — obligatorio por capa

```
test/
├── features/
│   └── <feature>/
│       ├── domain/          # unit tests puros (paquete `test`)
│       ├── data/             # tests del Mock*RepositoryImpl
│       └── presentation/      # widget tests (`flutter_test`): loading, éxito, error, vacío
└── shared/                  # mismo split domain/data/widgets, espejo de lib/shared/
    ├── domain/
    ├── data/
    └── widgets/
```

`test/shared/` espeja lo que vive en `lib/shared/` (ver regla del segundo consumidor). No hay
`test/shared/presentation/controllers/` — un controller compartido se prueba a través del widget
que lo consume (ej. `sensorHistoryControllerProvider` vía `test/shared/widgets/
sensor_history_chart_test.dart`), no con un `ProviderContainer` aislado — mismo criterio que ya se
usa para los controllers de feature (`DashboardController`, `AuthController`, etc.), probados por
sus widget tests de flujo, no por unit tests propios.

Usa `mocktail` para mockear interfaces de repositorio en tests de `domain` y `presentation` (no
requiere generación de código). Una feature no está terminada sin al menos un test por capa, en
verde.

**Gotchas conocidos (descubiertos construyendo `auth`/`dashboard`, evita re-descubrirlos):**
- **Providers que devuelven un tipo concreto en vez de la interfaz de domain** (ej.
  `AuthRepositoryImpl` en vez de `AuthRepository`) rompen `overrideWithValue` en tests con un mock
  que solo implementa la interfaz. El provider de un repositorio siempre debe anotar el tipo de
  retorno como la interfaz abstracta.
- **`tester.binding.setSurfaceSize` no actualiza `MediaQuery`** en este entorno de test
  (multi-view) — widgets que leen `MediaQuery.sizeOf(context)` (ej. `ResponsiveDeviceGrid` para
  columnas) no ven el cambio aunque `LayoutBuilder` sí. Usa también `tester.view.physicalSize` +
  `tester.view.devicePixelRatio` (con `tester.view.resetPhysicalSize()`/
  `resetDevicePixelRatio()` en el teardown) al fijar tamaños de pantalla en tests.
- **Riverpod reintenta indefinidamente por defecto** ante un error de un provider (`retry`
  ilimitado con backoff exponencial hasta 6.4s). Para un `StreamNotifier` sobre un stream mock que
  no se recupera solo, esto hace que `pumpAndSettle` nunca se asiente — desactívalo con
  `@Riverpod(retry: (retryCount, error) => null)` cuando el error no sea transitorio.
- **Tests de un `StreamNotifier` que llegan a `AsyncError` necesitan `tester.runAsync(...)`**
  alrededor de la espera — `tester.pump()`/`pumpAndSettle()` solos no bastan para que el error de
  un `Stream` externo (no un `Future`) se propague al widget en este entorno.
- **`AppTypographyTokens` (de `atomic_design`) no expone `fontFamilyMono`** aunque el JSON de
  config lo define — solo lee `fontFamily`. Si necesitas la fuente mono en una pantalla, hoy toca
  un literal `'JetBrains Mono'` puntual (documentado en el sitio de uso) hasta que se arregle en el
  paquete.
- **El plugin `code-review` necesita un repo git inicializado** (usa diffs/`gh`) — si el repo
  todavía no tiene git, no hay review automático posible. Si eso pasa, dilo explícitamente en vez
  de hacer una revisión manual silenciosa, y sugiere `git init` + primer commit antes de seguir.
- **Extender una interfaz de `shared/domain` (ej. `DeviceRepository`) rompe la compilación de su
  implementación mock existente**, usada por features ya completas. Patrón aceptado: agregar el
  método nuevo a la implementación con un stub explícito (`throw UnimplementedError()` +
  comentario `TODO` apuntando a qué paso lo resuelve) — nunca en silencio, y solo si el paso que
  lo implementa de verdad ya está planeado como el siguiente inmediato (no como "algún día").
- **Un `StreamNotifier`/`AsyncNotifier` con parámetros extra en `build()` (ej.
  `build(String deviceId)`) se vuelve family automáticamente** — `riverpod_generator` lo detecta
  solo, no hace falta (ni existe ya) un modificador `.family` explícito. Se consume como
  `ref.watch(deviceDetailControllerProvider(deviceId))` y se sobreescribe en tests igual que
  cualquier provider (`overrideWithValue` sobre el repositorio del que depende, no sobre el
  provider family en sí). Dos providers family independientes (`deviceDetailControllerProvider` y
  `sensorHistoryControllerProvider`) es intencional cuando cada uno cachea por una clave distinta
  (`deviceId` vs `sensorId`) — no los fusiones en uno solo "para simplificar".
- **`context.push`/`context.go` (extensiones de `go_router`) necesitan un `GoRouter` real como
  ancestro** — un `MaterialApp(home: MiPagina())` sin `routerConfig` no alcanza y tira en runtime
  si la pantalla navega así. En el widget test, arma un `GoRouter` mínimo con las rutas relevantes
  y usa `MaterialApp.router(routerConfig: router)` en vez de `MaterialApp(home: ...)`.
- **Un `CustomPaint` propio no es fácil de aislar con `find.byType(CustomPaint)`** — `Scaffold`/
  `Material` ya pintan los suyos, así que ese finder sobre-matchea. Con `fl_chart` esto se resuelve
  solo (`find.byType(LineChart)` es específico); si en el futuro se vuelve a necesitar un
  `CustomPainter` a mano, usa `find.byWidgetPredicate` comparando
  `widget.painter.runtimeType.toString()` en vez de contar `CustomPaint` a secas.
- **`mocktail`'s `any()`/`captureAny()` con un tipo propio (enum incluido) necesita
  `registerFallbackValue(...)` en `setUpAll`** antes de usarse — si no, el mock explota con "A test
  tried to use `any` ... but registerFallbackValue was not previously called". Pasó al agregar
  `any()` para `SensorHistoryRange` en tests que mockean `SensorHistoryRepository.getHistoryForRange`.
  Solo hace falta en los archivos que realmente usan `any()`/`captureAny()` para ese tipo, no en
  todos los que mockean la interfaz.
- **Una `ListView` no lazy (`ListView(children: [...])`) igual virtualiza sus hijos** — solo monta
  los widgets dentro del viewport + `cacheExtent` (250px por defecto), no absolutamente todos solo
  porque la lista se construyó de una vez. Con cards más altas (ej. `SensorHistoryDetailChart`, más
  grande que el sparkline compacto anterior), un widget al final de la lista (`RecentAlertsPlaceholder`)
  puede quedar fuera de esa ventana y `find.text`/`find.byType` no lo encuentran aunque exista
  lógicamente en la lista — no es un bug de la pantalla. Usa
  `await tester.scrollUntilVisible(finder, delta)` antes de la aserción en vez de asumir que todo
  está montado.

---

## Las 5 pantallas de la demo

1. **Login** (`features/auth`) — email/password mock, asigna rol (`operador` / `administrador`).
   **Completa.**
2. **Dashboard general** (`features/dashboard`) — KPIs + grid de dispositivos (`ResponsiveDeviceGrid`,
   no `AppGridView`) con badge de estado (online/warning/critical/offline), búsqueda/filtro, y un
   mini-gráfico de tendencia por card (un sensor a la vez, con selector si hay más de uno) que
   navega al detalle real al tocar la card. **Completa.**
3. **Detalle de dispositivo** (`features/device_detail`) — header con nombre/badge/última conexión
   (textos a tamaño legible, no `.caption`/`.label` diminutos), una card grande por sensor con su
   historial completo (`SensorHistoryDetailChart`: ejes, selector día/semana/mes, tooltip), y una
   sección de "alertas recientes" que hoy es un placeholder visual (`RecentAlertsPlaceholder`, sin
   ruta ni lógica propia) hasta que exista `alerts`. **Completa.**
4. **Alertas** (`features/alerts`) — lista filtrable por severidad/estado, con "Reconocer". No
   existe todavía — al construirla, reemplazar `RecentAlertsPlaceholder` por la sección real.
5. **Setpoints** (`features/setpoints`) — editable solo si el rol es `administrador`; al guardar,
   agrega una línea de auditoría visible (`"Modificado por {usuario} el {fecha}"`). No existe
   todavía.

## Modelo de datos mock (resumen)

Jerarquía obligatoria, aunque el mock solo tenga un tenant: `Tenant → Site → Device → Sensor`
(misma jerarquía que la convención de topics MQTT del proyecto real
`meclab/{tenant_id}/{site_id}/{device_id}/{sensor}`).

- **Tenant/Site**: nombre **ficticio** (nunca el cliente real).
- **Device**: id, site_id, nombre, tipo (compresor/motor/bomba/banda), estado
  (`online`/`warning`/`critical`/`offline` — 4 valores, no 3; `warning`/`critical` son estados del
  propio `Device`, no solo severidades de `Alert`), última conexión, `sensorCount` (total de
  sensores del device) y `keySensors` (snapshot para la card del dashboard — no la lista completa,
  esa la resuelve `device_detail` vía `DeviceRepository.getSensorsForDevice`).
- **Sensor**: id, device_id, nombre, tipo (temperatura/presión/vibración/corriente/rpm), unidad,
  valor actual, rango seguro (min/max). El historial de lecturas no vive en la entidad `Sensor` —
  `MockDeviceDataSource` expone dos fuentes distintas vía `SensorHistoryRepository`
  (`shared/domain`): un buffer "vivo" acotado (40 lecturas, ~160s) por `watchSensorHistory`
  (`Stream`, usado por ambos charts), que se congela cuando el device pasa a offline; y una
  caminata aleatoria sintética por rango (día/semana/mes) por `getHistoryForRange` (`Future`,
  usado solo por `SensorHistoryDetailChart` en `device_detail`).
- **Alert**: id, device_id, sensor_id opcional, severidad (info/warning/critical), mensaje,
  timestamp, estado (activa/reconocida/resuelta).
- **Setpoint**: id, device_id, nombre, valor actual, rango (min/max), unidad, quién puede editarlo,
  último modificado por/cuándo.
- **User**: id, email, nombre, rol (operador/administrador).

Genera entre 4 y 6 dispositivos de fábrica, con al menos un caso online sin alertas, uno con
warning, uno con critical, y uno offline — para mostrar los 4 estados visuales sin depender de
aleatoriedad en cada render.

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
