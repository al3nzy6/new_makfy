import 'package:makfy_new/Models/SubCategory.dart';
import 'package:makfy_new/Models/User.dart';
import 'package:makfy_new/Models/customField.dart';

class Service {
  final int id;
  final String title;
  final String description;
  final String price;
  final List<String>? imageUrls;
  final List<CustomField>? customFields; // يمكن أن تكون nullable
  final String? insertedValues;
  final User user;
  final SubCategory? category;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrls,
    this.customFields,
    this.insertedValues,
    required this.user,
    this.category,
  });

  // Factory constructor لتحويل JSON إلى Service
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        price: json['price'],
        insertedValues: json['insertedValues'],
        imageUrls: List<String>.from(
            json['image_urls'] ?? []), // تحويل image_urls إلى قائمة
        customFields: json['custom_fields'] != null
            ? (json['custom_fields'] as List)
                .map((field) => CustomField.fromJson(field))
                .toList()
            : [], // تعيين null إذا كانت custom_fields غير موجودة
        user: json['user'] != null
            ? User.fromMap(json['user']) // تأكد من وجود `user` قبل التحويل
            : User(id: 0, name: "غير معروف"), // تعيين قيم افتراضية عند الحاجة
        category: json['category'] != null
            ? SubCategory.fromJson(json['category'])
            : null);
  }
  // تحويل Service إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'insertedValues': insertedValues,
      'image_urls': imageUrls ?? [],
      'custom_fields':
          customFields?.map((field) => field.toJson()).toList() ?? [],
      'user': user.toMap(),
      'category': category ?? [],
    };
  }

  // تحويل Service إلى Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description ?? '',
      'price': price,
      'insertedValues': insertedValues,
      'image_urls': imageUrls ?? [],
      'custom_fields':
          customFields?.map((field) => field.toJson()).toList() ?? [],
      'user': user.toMap(), // تحويل كائن user إلى Map
      'category': category ?? [],
    };
  }
}
