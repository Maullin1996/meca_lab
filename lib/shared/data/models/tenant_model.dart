import '../../domain/entities/tenant.dart';

class TenantModel {
  final String id;
  final String name;

  const TenantModel({required this.id, required this.name});

  factory TenantModel.fromEntity(Tenant tenant) =>
      TenantModel(id: tenant.id, name: tenant.name);

  Tenant toEntity() => Tenant(id: id, name: name);

  factory TenantModel.fromJson(Map<String, dynamic> json) => TenantModel(
    id: json['id'] as String,
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
