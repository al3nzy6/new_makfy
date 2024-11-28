import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:makfy_new/Models/Service.dart';
import 'package:makfy_new/Models/User.dart';

class Cart extends Equatable {
  int id;
  User customer;
  User service_provider;
  int status;
  int? otp;
  double price;
  double total;
  String payment_id;
  String payment_time;
  String? service_time;
  String? choosenDate;
  String? choosenTime;
  List<Service>? services;
  Cart({
    required this.id,
    required this.customer,
    required this.service_provider,
    required this.status,
    this.otp,
    required this.price,
    required this.total,
    required this.payment_id,
    required this.payment_time,
    this.service_time,
    this.services,
    this.choosenDate,
    this.choosenTime,
  });

  Cart copyWith({
    int? id,
    User? customer,
    User? service_provider,
    int? status,
    int? otp,
    double? price,
    double? total,
    String? payment_id,
    String? payment_time,
    String? service_time,
    String? choosenDate,
    String? choosenTime,
    List<Service>? services,
  }) {
    return Cart(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      service_provider: service_provider ?? this.service_provider,
      status: status ?? this.status,
      otp: otp ?? this.otp,
      price: price ?? this.price,
      total: total ?? this.total,
      service_time: service_time ?? this.service_time,
      payment_id: payment_id ?? this.payment_id,
      payment_time: payment_time ?? this.payment_time,
      choosenDate: choosenDate ?? this.choosenDate,
      choosenTime: choosenTime ?? this.choosenTime,
      services: services ?? this.services,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'customer': customer.toMap()});
    result.addAll({'service_provider': service_provider.toMap()});
    result.addAll({'status': status});
    result.addAll({'otp': otp});
    result.addAll({'price': price});
    result.addAll({'total': total});
    result.addAll({'service_time': service_time});
    result.addAll({'payment_id': payment_id});
    result.addAll({'payment_time': payment_time});
    result.addAll({'choosenDate': choosenDate});
    result.addAll({'choosenTime': choosenTime});
    if (services != null) {
      result.addAll({'services': services!.map((x) => x?.toMap()).toList()});
    }

    return result;
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id']?.toInt() ?? 0,
      customer: User.fromMap(map['customer']),
      service_provider: User.fromMap(map['service_provider']),
      status: map['status']?.toInt() ?? 0,
      otp: map['otp']?.toInt() ?? 0,
      price: map['price'] ?? '',
      total: map['total'] ?? '',
      service_time: map['service_time'] ?? '',
      payment_id: map['payment_id'] ?? '',
      payment_time: map['payment_time'] ?? '',
      choosenDate: map['choosenDate'] ?? '',
      choosenTime: map['choosenTime'] ?? '',
      services: map['services'] != null
          ? List<Service>.from(map['services']?.map((x) => Service.fromMap(x)))
          : null,
    );
  }

  static List<Cart> sortById(List<Cart> carts, {bool descending = false}) {
    carts.sort(
        (a, b) => descending ? b.id.compareTo(a.id) : a.id.compareTo(b.id));
    return carts;
  }

  String toJson() => json.encode(toMap());

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      customer: User.fromJson(json['customer']),
      service_provider: User.fromJson(json['service_provider']),
      status: json['status'],
      otp: json['otp'],
      service_time: json['service_time'],
      price: json['price'] != null
          ? double.parse(json['price'].replaceAll(',', ''))
          : 0.0,
      total: json['total'] != null
          ? double.parse(json['total'].replaceAll(',', ''))
          : 0.0,
      payment_id: json['payment_id'] ?? '',
      payment_time: json['payment_time'] ?? '',
      choosenDate: json['choosenDate'] ?? '',
      choosenTime: json['choosenTime'] ?? '',
      services: (json['services'] as List)
          .map((serviceJson) => Service.fromJson(serviceJson))
          .toList(),
    );
  }
  @override
  String toString() {
    return 'Cart(id: $id, customer: $customer, service_provider: $service_provider, status: $status, price: $price, total: $total, payment_id: $payment_id, payment_time: $payment_time, services: $services)';
  }

  @override
  List<Object> get props {
    return [
      id,
      customer,
      service_provider,
      status,
      price,
      total,
      payment_id,
      payment_time,
      services ?? [],
    ];
  }
}
