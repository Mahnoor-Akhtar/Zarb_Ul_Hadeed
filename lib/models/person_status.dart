/// Pure data class representing a person's current duty/status assignment.
/// Extracted from personnel_data_manager.dart for the models layer.
class PersonStatus {
  String category;
  String? subcategory;
  String? subSubcategory;
  final DateTime startDate;
  final DateTime? endDate;

  PersonStatus({
    required this.category,
    this.subcategory,
    this.subSubcategory,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'category': category,
        'subcategory': subcategory,
        'subSubcategory': subSubcategory,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      };

  factory PersonStatus.fromJson(Map<String, dynamic> json) => PersonStatus(
        category: json['category'] as String,
        subcategory: json['subcategory'] as String?,
        subSubcategory: json['subSubcategory'] as String?,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
      );

  String get displayPath {
    final List<String> parts = [category];
    if (subcategory != null) parts.add(subcategory!);
    if (subSubcategory != null) parts.add(subSubcategory!);
    return parts.join(' -> ');
  }
}
