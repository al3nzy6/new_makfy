import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:makfy_new/Models/District.dart';

class City extends Equatable {
  final int id;
  final String name;
  final List<District>? districts;

  City({
    required this.id,
    required this.name,
    this.districts,
  });

  City copyWith({
    int? id,
    String? name,
    List<District>? districts,
  }) {
    return City(
      id: id ?? this.id,
      name: name ?? this.name,
      districts: districts ?? this.districts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'districts': districts?.map((x) => x.toMap()).toList(),
    };
  }

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      districts: map['districts'] != null
          ? List<District>.from(
              (map['districts'] as List).map((x) => District.fromMap(x)))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory City.fromJson(String source) => City.fromMap(json.decode(source));

  @override
  String toString() => 'City(id: $id, name: $name)';

  @override
  List<Object?> get props => [id, name, districts];
}
