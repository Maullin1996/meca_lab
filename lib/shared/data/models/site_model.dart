import '../../domain/entities/site.dart';

class SiteModel {
  final String id;
  final String tenantId;
  final String name;

  const SiteModel({
    required this.id,
    required this.tenantId,
    required this.name,
  });

  factory SiteModel.fromEntity(Site site) => SiteModel(
    id: site.id,
    tenantId: site.tenantId,
    name: site.name,
  );

  Site toEntity() => Site(id: id, tenantId: tenantId, name: name);

  factory SiteModel.fromJson(Map<String, dynamic> json) => SiteModel(
    id: json['id'] as String,
    tenantId: json['tenant_id'] as String,
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tenant_id': tenantId,
    'name': name,
  };
}
