/// Coarser time window for a one-shot historical read
/// ([SensorHistoryRepository.getHistoryForRange]), independent of the live,
/// short buffer behind [SensorHistoryRepository.watchSensorHistory]. Only
/// `device_detail`'s full chart uses this today — `dashboard`'s mini-charts
/// stay on the live stream.
enum SensorHistoryRange { day, week, month }
