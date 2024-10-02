import 'dart:convert';

import 'package:makfy_new/Models/Service.dart';
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
  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.percentage,
    required this.serviceType,
    this.categories,
    this.Fields,
    this.services,
  });

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
    };
  }
}
