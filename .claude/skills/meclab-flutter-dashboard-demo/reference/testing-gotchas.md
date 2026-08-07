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
