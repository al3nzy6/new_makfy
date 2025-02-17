import 'dart:convert';

import 'package:equatable/equatable.dart';

class Vacation extends Equatable {
  int id;
  int user_id;
  String vacation_from;
  String vacation_to;
  Vacation({
    required this.id,
    required this.user_id,
    required this.vacation_from,
    required this.vacation_to,
  });

  @override
  List<Object> get props => [id, user_id, vacation_from, vacation_to];

  Vacation copyWith({
    int? id,
    int? user_id,
    String? vacation_from,
    String? vacation_to,
  }) {
    return Vacation(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      vacation_from: vacation_from ?? this.vacation_from,
      vacation_to: vacation_to ?? this.vacation_to,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'user_id': user_id});
    result.addAll({'vacation_from': vacation_from});
    result.addAll({'vacation_to': vacation_to});

    return result;
  }

  factory Vacation.fromMap(Map<String, dynamic> map) {
    return Vacation(
      id: map['id']?.toInt() ?? 0,
      user_id: map['user_id']?.toInt() ?? 0,
      vacation_from: map['vacation_from'] ?? '',
      vacation_to: map['vacation_to'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Vacation.fromJson(String source) =>
      Vacation.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Vacation(id: $id, user_id: $user_id, vacation_from: $vacation_from, vacation_to: $vacation_to)';
  }
}
