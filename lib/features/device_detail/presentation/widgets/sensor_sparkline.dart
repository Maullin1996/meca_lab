import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/sensor_reading.dart';
import '../controllers/sensor_history_controller.dart';

/// Exclusive to `device_detail` today — doesn't belong in
/// `lib/shared/widgets/` until a second feature needs the same visual
/// (second-consumer rule).
///
/// Watches its own `sensorHistoryControllerProvider(sensorId)` independently
/// — each sensor card resolves its own history, it isn't handed down from
/// `device_detail_page.dart`.
class SensorSparkline extends ConsumerWidget {
  final String sensorId;
  final double height;

  const SensorSparkline({super.key, required this.sensorId, this.height = 40});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(sensorHistoryControllerProvider(sensorId));
    final colors = AppColors.of(context);

    final readings = historyState.value;
    if (readings == null || readings.length < 2) {
      return SizedBox(height: height);
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(readings: readings, color: colors.primary),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<SensorReading> readings;
  final Color color;

  _SparklinePainter({required this.readings, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final values = [for (final reading in readings) reading.value];
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue).abs() < 1e-9 ? 1.0 : maxValue - minValue;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final normalized = (values[i] - minValue) / range;
      final y = size.height - normalized * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.readings != readings || oldDelegate.color != color;
}
