import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:makfy_new/Models/Service.dart';

class User extends Equatable {
  int id;
  String name;
  int? averageRating;
  String? countRating;
  List<Service>? services;
  User({
    required this.id,
    required this.name,
    this.averageRating,
    this.countRating,
    this.services,
  });

  User copyWith({
    int? id,
    String? name,
    List<Service>? services,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      averageRating: averageRating ?? this.averageRating,
      countRating: countRating ?? this.countRating,
      services: services ?? this.services,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'averageRating': averageRating});
    result.addAll({'countRating': countRating});

    return result;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      averageRating: map['averageRating']?.toInt() ?? 0,
      countRating: map['countRating'] ?? '',
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      averageRating: json['averageRating'],
      countRating: json['countRating'],
      services: json['services'] != null
          ? (json['services'] as List)
              .map((servicesJson) => Service.fromJson(servicesJson))
              .toList()
          : [],
    );
  }

  String toJson() => json.encode(toMap());
  @override
  String toString() => 'User(id: $id, name: $name)';

  @override
  List<Object> get props => [id, name];
}
