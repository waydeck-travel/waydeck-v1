import 'package:freezed_annotation/freezed_annotation.dart';

part 'checklist_template.freezed.dart';
part 'checklist_template.g.dart';

/// Checklist Template model
/// Represents a reusable checklist template
@freezed
class ChecklistTemplateModel with _$ChecklistTemplateModel {
  const factory ChecklistTemplateModel({
    required String id,
    required String ownerId,
    required String name,
    String? description,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ChecklistTemplateModel;

  factory ChecklistTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$ChecklistTemplateModelFromJson(_convertJsonKeys(json));

  static Map<String, dynamic> _convertJsonKeys(Map<String, dynamic> json) {
    return {
      'id': json['id'],
      'ownerId': json['owner_id'],
      'name': json['name'],
      'description': json['description'],
      'icon': json['icon'],
      'createdAt': json['created_at'],
      'updatedAt': json['updated_at'],
    };
  }
}

/// Checklist Template Item model
/// Represents an item within a checklist template
@freezed
class ChecklistTemplateItemModel with _$ChecklistTemplateItemModel {
  const factory ChecklistTemplateItemModel({
    required String id,
    required String templateId,
    required String title,
    String? category, // packing, documents, shopping, etc.
    String? phase, // before_trip, during_trip, after_trip
    int? sortOrder,
  }) = _ChecklistTemplateItemModel;

  factory ChecklistTemplateItemModel.fromJson(Map<String, dynamic> json) =>
      _$ChecklistTemplateItemModelFromJson(_convertJsonKeys(json));

  static Map<String, dynamic> _convertJsonKeys(Map<String, dynamic> json) {
    return {
      'id': json['id'],
      'templateId': json['template_id'],
      'title': json['title'],
      'category': json['category'],
      'phase': json['phase'],
      'sortOrder': json['sort_order'],
    };
  }
}
