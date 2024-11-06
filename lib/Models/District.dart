import 'dart:convert';

import 'package:equatable/equatable.dart';

class District extends Equatable {
  int id;
  String name;
  District({
    required this.id,
    required this.name,
  });

  District copyWith({
    int? id,
    String? name,
  }) {
    return District(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});

    return result;
  }

  factory District.fromMap(Map<String, dynamic> map) {
    return District(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory District.fromJson(String source) =>
      District.fromMap(json.decode(source));

  @override
  String toString() => 'District(id: $id, name: $name)';

  @override
  List<Object> get props => [id, name];
}
