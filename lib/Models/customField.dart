import 'package:makfy_new/Models/Option.dart';

class CustomField {
  final int id;
  final String showName;
  final String name;
  final String type;
  final String? value; // يمكن أن يكون String أو List
  final String? insertedValue;
  final bool required;
  final List<Option>? options;

  CustomField({
    required this.id,
    required this.showName,
    required this.name,
    required this.type,
    this.value,
    this.insertedValue,
    required this.required,
    this.options,
  });

  // Factory constructor لتحويل JSON إلى CustomField
  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      id: json['id'] ?? 0,
      showName: json['showName'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      value: json['value'] ?? '', // احتفظنا بقيمة `value` كما هي بدون تحويل
      insertedValue: json['inserted_value'] ?? '',
      required: json['required'] ?? false,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((option) => Option.fromJson(option))
              .toList()
          : null,
    );
  }

  // تحويل CustomField إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'showName': showName,
      'name': name,
      'type': type,
      'value': value,
      'inserted_value': insertedValue,
      'required': required,
      'options': options?.map((option) => option.toMap()).toList(),
    };
  }

  // تحويل CustomField إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'showName': showName,
      'name': name,
      'type': type,
      'value': value,
      'inserted_value': insertedValue,
      'required': required,
      'options': options?.map((option) => option.toJson()).toList(),
    };
  }

  factory CustomField.fromMap(Map<String, dynamic> map) {
    return CustomField(
      id: map['id'] ?? 0,
      showName: map['showName'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      value: map['value'] ?? '', // احتفظنا بـ `value` بدون تعديل
      insertedValue: map['inserted_value'] ?? '',
      required: map['required'] ?? false,
      options: map['options'] != null
          ? List<Option>.from(map['options']?.map((x) => Option.fromMap(x)))
          : null,
    );
  }
}
