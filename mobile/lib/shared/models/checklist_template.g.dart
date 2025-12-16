// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChecklistTemplateModelImpl _$$ChecklistTemplateModelImplFromJson(
  Map<String, dynamic> json,
) => _$ChecklistTemplateModelImpl(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  icon: json['icon'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$ChecklistTemplateModelImplToJson(
  _$ChecklistTemplateModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'ownerId': instance.ownerId,
  'name': instance.name,
  'description': instance.description,
  'icon': instance.icon,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_$ChecklistTemplateItemModelImpl _$$ChecklistTemplateItemModelImplFromJson(
  Map<String, dynamic> json,
) => _$ChecklistTemplateItemModelImpl(
  id: json['id'] as String,
  templateId: json['templateId'] as String,
  title: json['title'] as String,
  category: json['category'] as String?,
  phase: json['phase'] as String?,
  sortOrder: (json['sortOrder'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ChecklistTemplateItemModelImplToJson(
  _$ChecklistTemplateItemModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'templateId': instance.templateId,
  'title': instance.title,
  'category': instance.category,
  'phase': instance.phase,
  'sortOrder': instance.sortOrder,
};
