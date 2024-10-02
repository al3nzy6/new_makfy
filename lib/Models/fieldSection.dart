import 'package:makfy_new/Models/Option.dart';

class fieldSection {
  final int id;
  final String name;
  final String showName;
  final String type;
  final bool required;
  final List<Option>? options;

  fieldSection({
    required this.id,
    required this.name,
    required this.showName,
    required this.type,
    required this.required,
    this.options,
  });

  // Factory constructor to parse JSON
  factory fieldSection.fromJson(Map<String, dynamic> json) {
    return fieldSection(
      id: json['id'],
      name: json['name'],
      showName: json['showName'],
      type: json['type'],
      required: json['required'],
      options: json['options'] != null
          ? (json['options'] as List)
              .map((optionJson) => Option.fromJson(optionJson))
              .toList()
          : [],
    );
  }

  // Convert fieldSection object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'showName': showName,
      'type': type,
      'required': required,
      'options': options?.map((option) => option.toJson()).toList() ?? [],
    };
  }
}
