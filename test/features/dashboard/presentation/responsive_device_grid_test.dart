import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/features/dashboard/presentation/widgets/responsive_device_grid.dart';

void main() {
  group('ResponsiveDeviceGrid.columnCountForWidth', () {
    test('menos de 450px es 1 columna', () {
      expect(ResponsiveDeviceGrid.columnCountForWidth(0), 1);
      expect(ResponsiveDeviceGrid.columnCountForWidth(449), 1);
    });

    test('de 450px a 889px son 2 columnas', () {
      expect(ResponsiveDeviceGrid.columnCountForWidth(450), 2);
      expect(ResponsiveDeviceGrid.columnCountForWidth(889), 2);
    });

    test('de 890px a 1439px son 3 columnas', () {
      expect(ResponsiveDeviceGrid.columnCountForWidth(890), 3);
      expect(ResponsiveDeviceGrid.columnCountForWidth(1439), 3);
    });

    test('de 1440px a 1919px son 4 columnas', () {
      expect(ResponsiveDeviceGrid.columnCountForWidth(1440), 4);
      expect(ResponsiveDeviceGrid.columnCountForWidth(1919), 4);
    });

    test('desde 1920px sigue sumando una columna cada ~480px', () {
      expect(ResponsiveDeviceGrid.columnCountForWidth(1920), 5);
      expect(ResponsiveDeviceGrid.columnCountForWidth(2399), 5);
      expect(ResponsiveDeviceGrid.columnCountForWidth(2400), 6);
    });
  });
}
