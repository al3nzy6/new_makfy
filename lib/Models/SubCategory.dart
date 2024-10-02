// Model for SubCategory inside the categories list
import 'package:makfy_new/Models/Category.dart';

class SubCategory {
  final int? id;
  final String name;
  final String? icon;

  SubCategory({
    this.id,
    required this.name,
    this.icon,
  });

  // Factory constructor to create a SubCategory from JSON
  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] ?? '',
      name: json['name'],
      icon: json['icon'] ?? '',
    );
  }

  // Convert SubCategory object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon ?? '',
    };
  }
}

// Function to parse the main response that contains a list of categories
class CategoryResponse {
  final List<Category> data;

  CategoryResponse({required this.data});

  // Factory method to parse the overall JSON response
  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      data: (json['data'] as List)
          .map((categoryJson) => Category.fromJson(categoryJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((category) => category.toJson()).toList(),
    };
  }
}
