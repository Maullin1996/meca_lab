import '../../../../shared/domain/entities/user_role.dart';
import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory UserModel.fromEntity(User user) => UserModel(
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
      );

  User toEntity() => User(id: id, email: email, name: name, role: role);

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        role: UserRole.values.byName(json['role'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role.name,
      };
}
