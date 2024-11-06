import 'dart:convert';

import 'package:makfy_new/Models/Service.dart';
import 'package:makfy_new/Models/User.dart';
import 'package:makfy_new/Models/fieldSection.dart';
import 'package:makfy_new/Models/SubCategory.dart';
import 'package:makfy_new/Screens/subsectionPage.dart';

class Category {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final String? percentage;
  final int serviceType;
  final List<fieldSection>? Fields;
  final List<SubCategory>? categories;
  final List<Service>? services;
  final List<User>? service_providers;
  Category(
      {required this.id,
      required this.name,
      this.description,
      this.icon,
      this.percentage,
      required this.serviceType,
      this.categories,
      this.Fields,
      this.services,
      this.service_providers});

  // Factory constructor to create a Category from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      percentage: json['percentage'],
      serviceType: json['service_type'],
      // Map subcategories JSON to a List<SubCategory>
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((subCategoryJson) => SubCategory.fromJson(subCategoryJson))
              .toList()
          : [],
      // Map subcategories JSON to a List<SubCategory>
      Fields: json['Fields'] != null
          ? (json['Fields'] as List)
              .map((fieldJson) => fieldSection.fromJson(fieldJson))
              .toList()
          : [],
      services: json['services'] != null
          ? (json['services'] as List)
              .map((servicesJson) => Service.fromJson(servicesJson))
              .toList()
          : [], // Can be null or another type
      service_providers: json['service_providers'] != null
          ? (json['service_providers'] as List)
              .map((userJson) => User.fromJson(userJson))
              .toList()
          : [], // Can be null or another type
    );
  }

  // Convert Category object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'percentage': percentage,
      'service_type': serviceType,
      'categories':
          categories?.map((subCategory) => subCategory.toJson()).toList() ?? [],
      'Fields':
          Fields?.map((fiedSection) => fiedSection.toJson()).toList() ?? [],
      'services': services?.map((service) => service.toJson()).toList() ?? [],
      'service_providers': service_providers
              ?.map((service_provider) => service_provider.toJson())
              .toList() ??
          [],
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      description: map['description']?.toString(),
      icon: map['icon']?.toString(),
      percentage: map['percentage']?.toString(),
      serviceType: map['service_type']?.toInt() ?? 0,
      categories: map['categories'] != null
          ? (map['categories'] as List)
              .map((subCategoryMap) => SubCategory.fromMap(subCategoryMap))
              .toList()
          : [],
      Fields: map['Fields'] != null
          ? (map['Fields'] as List)
              .map((fieldMap) => fieldSection.fromMap(fieldMap))
              .toList()
          : [],
      services: map['services'] != null
          ? (map['services'] as List)
              .map((serviceMap) => Service.fromMap(serviceMap))
              .toList()
          : [],
      service_providers: map['service_providers'] != null
          ? (map['service_providers'] as List)
              .map((userMap) => User.fromMap(userMap))
              .toList()
          : [],
    );
  }
}
