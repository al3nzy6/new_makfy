import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:makfy_new/Models/City.dart';

class District extends Equatable {
  final int id;
  final String name;
  final City? city; // المدينة المرتبطة بالحي

  District({
    required this.id,
    required this.name,
    this.city,
  });

  District copyWith({
    int? id,
    String? name,
    City? city,
  }) {
    return District(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city?.toMap(), // تحويل كائن City إلى Map إذا كان غير null
    };
  }

  factory District.fromMap(Map<String, dynamic> map) {
    return District(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      city: map.containsKey('city') ? City.fromMap(map['city']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory District.fromJson(String source) =>
      District.fromMap(json.decode(source));

  @override
  String toString() => 'District(id: $id, name: $name)';

  @override
  List<Object?> get props => [id, name, city];
}
