// In societies_model.dart
class Society {
  final int? id;
  final String? createdDate;
  final String? deleteField;
  final String? society;
  final String? societyCode;
  final String? societyPreCode;
  final String? newSocietyPreCode;
  final int? districtTblForeignKey;

  Society({
    this.id,
    this.createdDate,
    this.deleteField,
    this.society,
    this.societyCode,
    this.societyPreCode,
    this.newSocietyPreCode,
    this.districtTblForeignKey,
  });

  factory Society.fromJson(Map<String, dynamic> json) {
    return Society(
      id: (json['_id'] ?? json['id']) as int?,
      createdDate: json['created_date']?.toString(),
      deleteField: json['delete_field']?.toString(),
      society: json['society']?.toString(),
      societyCode: json['society_code']?.toString(),
      societyPreCode: json['society_pre_code']?.toString(),
      newSocietyPreCode: json['new_society_pre_code']?.toString(),
      districtTblForeignKey: json['districtTbl_foreignkey'] as int?,
    );
  }

 Map<String, dynamic> toJson() {
  final map = {
    'id': id,
    'created_date': createdDate ?? DateTime.now().toIso8601String(),
    'delete_field': deleteField ?? 'no',
    'society': society ?? '',
    'society_code': societyCode ?? '',
    'society_pre_code': societyPreCode ?? '',
    'new_society_pre_code': newSocietyPreCode ?? '',
    'districtTbl_foreignkey': districtTblForeignKey ?? 0,
  }..removeWhere((key, value) => value == null);
  
  return map;
}
}