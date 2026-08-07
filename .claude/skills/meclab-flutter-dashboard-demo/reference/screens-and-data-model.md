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
