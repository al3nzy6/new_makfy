import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:makfy_new/Models/Service.dart';

class User extends Equatable {
  int id;
  String name;
  String? email;
  int? averageRating;
  String? phone;
  String? nationality;
  String? bank;
  String? iban;
  String? id_number;
  String? countRating;
  String? start_time;
  String? end_time;
  String? order_limit_per_day;
  double? delivery_fee;

  List<Service>? services;
  User({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.nationality,
    this.bank,
    this.iban,
    this.id_number,
    this.averageRating,
    this.countRating,
    this.start_time,
    this.end_time,
    this.services,
    this.order_limit_per_day,
    this.delivery_fee,
  });

  User copyWith({
    int? id,
    String? name,
    String? phone,
    List<Service>? services,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      order_limit_per_day: order_limit_per_day ?? this.order_limit_per_day,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      delivery_fee: delivery_fee ?? this.delivery_fee,
      nationality: nationality ?? this.nationality,
      bank: bank ?? this.bank,
      iban: iban ?? this.iban,
      start_time: start_time ?? this.start_time,
      end_time: end_time ?? this.end_time,
      id_number: id_number ?? this.id_number,
      averageRating: averageRating ?? this.averageRating,
      countRating: countRating ?? this.countRating,
      services: services ?? this.services,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'email': email});
    result.addAll({'phone': phone});
    result.addAll({'delivery_fee': delivery_fee});
    result.addAll({'nationality': nationality});
    result.addAll({'bank': bank});
    result.addAll({'iban': iban});
    result.addAll({'id_number': id_number});
    result.addAll({'averageRating': averageRating});
    result.addAll({'countRating': countRating});
    result.addAll({'start_time': start_time});
    result.addAll({'end_time': end_time});
    result.addAll({'order_limit_per_day': order_limit_per_day});

    return result;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      delivery_fee: map['delivery_fee']?.toDouble() ?? 0.0,
      email: map['email'] ?? '',
      nationality: map['nationality'] ?? '',
      bank: map['bank'] ?? '',
      iban: map['iban'] ?? '',
      id_number: map['id_number'] ?? '',
      end_time: map['end_time'] ?? '',
      order_limit_per_day: map['order_limit_per_day'] ?? '',
      start_time: map['start_time'] ?? '',
      averageRating: map['averageRating']?.toInt() ?? 0,
      countRating: map['countRating'] ?? '',
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      delivery_fee: json['delivery_fee'] is num
          ? (json['delivery_fee'] as num).toDouble()
          : double.tryParse(json['delivery_fee'].toString()) ?? 0.0,
      nationality: json['nationality'],
      bank: json['bank'],
      iban: json['iban'],
      id_number: json['id_number'],
      start_time: json['start_time'],
      end_time: json['end_time'],
      order_limit_per_day: json['order_limit_per_day'],
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
  String toString() => 'User(id: $id, name: $name, phone: $phone)';

  @override
  List<Object> get props => [id, name];
}
