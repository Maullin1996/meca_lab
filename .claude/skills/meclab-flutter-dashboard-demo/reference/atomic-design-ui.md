## Qué componente de `atomic_design` usar en cada pantalla

No construyas estos widgets desde cero — el paquete ya los tiene:

| Pantalla               | Componentes de `atomic_design` a reutilizar                                                                                                                                                                                                                                                                                                                                                                                                       |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Login                  | **No uses `AppLoginForm`** — no es responsive para web y el diseño no encaja con lo que se busca aquí. Compón la pantalla a medida con los átomos/moléculas de `atomic_design` (`AppInputText`, `AppButtons`, `AppText`, `AppCard`), con layout propio responsive (ver regla de UI a medida abajo)                                                                                                                                                |
| Dashboard general      | `AppSearchBar` (buscador), `AppCard` (KPIs y cada `DeviceCard`), `AppDrawer`/`AppBottomNavBar` según breakpoint, `AppStateWidget` para vacío/error. **No `AppGridView`** para la grilla de dispositivos — ver `ResponsiveDeviceGrid` más abajo. Cada `DeviceCard` grafica un solo sensor a la vez (`SensorHistoryChart` en modo `compact`), con un menú para elegir cuál si el device tiene más de uno — ver "Un solo gráfico por card" más abajo |
| Detalle de dispositivo | `AppCard` por sensor (`SensorDetailCard`), `AppText` para valores, `AppStateWidget` para vacío/error, `SensorHistoryDetailChart` (widget exclusivo de la feature, no `SensorHistoryChart`) con ejes X/Y, selector de rango día/semana/mes y tooltip al pasar el mouse                                                                                                                                                                             |
| Alertas                | `AppCardList` (loading/empty/error/list) para la lista, `AppSnackBar` al reconocer una alerta                                                                                                                                                                                                                                                                                                                                                     |
| Setpoints              | `AppCard` + `AppButtons`, `AppDialog` o `AppBottomSheet` para confirmar el cambio, `AppSnackBar` para la confirmación final                                                                                                                                                                                                                                                                                                                       |

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
_orquestación_ de _composición visual_, nunca dupliques la lógica completa en dos pantallas
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
