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
  double? delivery_fee;
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
    this.delivery_fee,
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
    double? delivery_fee,
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
      delivery_fee: delivery_fee ?? this.delivery_fee,
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
    result.addAll({'delivery_fee': delivery_fee});
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
      price: map['price'] != null
          ? double.tryParse(map['price'].toString()) ?? 0.0
          : 0.0,
      total: map['total'] != null
          ? double.tryParse(map['total'].toString()) ?? 0.0
          : 0.0,
      service_time: map['service_time'] ?? '',
      payment_id: map['payment_id'] ?? '',
      payment_time: map['payment_time'] ?? '',
      choosenDate: map['choosenDate'] ?? '',
      choosenTime: map['choosenTime'] ?? '',
      delivery_fee: map['delivery_fee'] != null
          ? double.tryParse(map['delivery_fee'].toString()) ?? 0.0
          : 0.0,
      services: map['services'] != null
          ? List<Service>.from(map['services'].map((x) => Service.fromMap(x)))
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
      id: json['id'] ?? 0,
      customer: User.fromJson(json['customer']),
      service_provider: User.fromJson(json['service_provider']),
      status: json['status'] ?? 0,
      otp: json['otp'],
      service_time: json['service_time'] ?? '',
      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      total: json['total'] != null
          ? double.tryParse(json['total'].toString()) ?? 0.0
          : 0.0,
      payment_id: json['payment_id'] ?? '',
      payment_time: json['payment_time'] ?? '',
      choosenDate: json['choosenDate'] ?? '',
      choosenTime: json['choosenTime'] ?? '',
      delivery_fee: json['delivery_fee'] != null
          ? double.tryParse(json['delivery_fee'].toString()) ?? 0.0
          : 0.0,
      services: json['services'] != null
          ? (json['services'] as List)
              .map((serviceJson) => Service.fromJson(serviceJson))
              .toList()
          : [],
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

  String? getServiceNote(int serviceId) {
  try {
    final service = services?.firstWhere((s) => s.id == serviceId);
    return service?.notes;
  } catch (e) {
    return null;
  }
}
}
