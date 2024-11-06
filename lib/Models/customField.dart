import 'package:makfy_new/Models/Option.dart';

class CustomField {
  final String showName;
  final String name;
  final String type;
  final String value;
  final String insertedValue;
  final List<Option>? options; // يمكن أن تكون nullable

  CustomField({
    required this.showName,
    required this.name,
    required this.type,
    required this.value,
    required this.insertedValue,
    this.options,
  });

  // Factory constructor لتحويل JSON إلى CustomField
  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      showName: json['showName'],
      name: json['name'],
      type: json['type'],
      value: json['value'] ?? '',
      insertedValue: json['inserted_value'] ?? '',
      options: json['options'] != null
          ? (json['options'] as List)
              .map((option) => Option.fromJson(option))
              .toList()
          : null, // تعيين null إذا كانت options غير موجودة
    );
  }

  // تحويل CustomField إلى Map
  Map<String, dynamic> toJson() {
    return {
      'showName': showName,
      'name': name,
      'type': type,
      'value': value,
      'inserted_value': insertedValue,
      'options': options?.map((option) => option.toJson()).toList(),
    };
  }

  factory CustomField.fromMap(Map<String, dynamic> map) {
    return CustomField(
      showName: map['showName'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      value: map['value'] ?? '',
      insertedValue: map['inserted_value'] ?? '',
      options: map['options'] != null
          ? List<Option>.from(map['options']?.map((x) => Option.fromMap(x)))
          : null,
    );
  }
}
