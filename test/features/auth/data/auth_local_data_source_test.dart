import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/core/services/local_storage_service.dart';
import 'package:meca_lab/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:meca_lab/features/auth/data/models/user_model.dart';
import 'package:meca_lab/features/auth/domain/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const user = UserModel(
    id: 'usr-1',
    email: 'camila.rios@plantademo.meclab',
    name: 'Camila Ríos',
    role: UserRole.operador,
  );

  Future<AuthLocalDataSource> buildDataSource() async {
    final preferences = await SharedPreferences.getInstance();
    return AuthLocalDataSource(LocalStorageService(preferences));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('getSession devuelve null cuando no se ha guardado ninguna sesión', () async {
    final dataSource = await buildDataSource();

    final result = await dataSource.getSession();

    expect(result, isNull);
  });

  test('getSession recupera lo guardado por saveSession', () async {
    final dataSource = await buildDataSource();

    await dataSource.saveSession(user);
    final result = await dataSource.getSession();

    expect(result?.id, user.id);
    expect(result?.email, user.email);
    expect(result?.name, user.name);
    expect(result?.role, user.role);
  });

  test('clearSession borra la sesión guardada', () async {
    final dataSource = await buildDataSource();

    await dataSource.saveSession(user);
    await dataSource.clearSession();
    final result = await dataSource.getSession();

    expect(result, isNull);
  });
}
