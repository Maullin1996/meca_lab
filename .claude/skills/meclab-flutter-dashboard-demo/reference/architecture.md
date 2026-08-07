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

Tres casos reales ya pasaron por esto (no son hipotéticos, son la referencia a seguir):

- **`DeviceStatusBadge`** nació en `dashboard/presentation/widgets/` (usado por `DeviceCard`) y
  subió a `shared/widgets/` cuando `device_detail` lo necesitó para su header.
- **`SensorHistoryChart`** nació en `device_detail/presentation/widgets/` (como `SensorSparkline`,
  sobre un `CustomPainter` propio) y subió a `shared/widgets/` — ya reescrito sobre `fl_chart` — al
  agregarle mini-gráficos a las cards del dashboard.
- **`AlertSeverityBadge`** nació en `features/alerts/presentation/widgets/` y subió a `shared/widgets/` cuando `device_detail` lo necesitó para su sección de alertas recientes.

**`lib/shared/domain/`** — mismo espíritu que `shared/widgets/`, pero para entidades y contratos de
repositorio que usa más de una feature: `Tenant`, `Site`, `Device`, `Sensor`, más la interfaz
`DeviceRepository` (compartidos desde el principio, por la sección "Modelo de datos mock").
`SensorReading` y `SensorHistoryRepository` empezaron exclusivos de `device_detail` y se
**promovieron** a `shared/domain` cuando `dashboard` los necesitó también (sparklines en las cards)
— ejemplo real de la regla del segundo consumidor operando como debía, no una excepción a ella.
`Alert` empezó exclusivo de `features/alerts` y se **promovió** a `shared/domain` cuando
`device_detail` lo necesitó para su sección de "alertas recientes del device" — mismo patrón que
`SensorReading`/`SensorHistoryRepository` un poco más arriba. `Setpoint` y `User` siguen siendo
exclusivos de su feature, esperando su propio segundo consumidor real.

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
la _fuente de datos_ en `data` no obliga a compartir la _entidad_ en `domain`.
