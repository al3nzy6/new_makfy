import 'package:makfy_new/Models/SubCategory.dart';
import 'package:makfy_new/Models/User.dart';
import 'package:makfy_new/Models/customField.dart';

class Service {
  final int id;
  final String title;
  final String description;
  final String price;
  final String priceWithOutCommission;
  final List<String>? imageUrls;
  final List<CustomField>? customFields; // يمكن أن تكون nullable
  final String? insertedValues;
  final User user;
  final bool is_available;
  final SubCategory? category;
  final int? quantity; // الحقل الجديد، يمكن أن يكون null

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.priceWithOutCommission,
    required this.is_available,
    this.imageUrls,
    this.customFields,
    this.insertedValues,
    required this.user,
    this.category,
    this.quantity, // إضافة الحقل كخيار اختياري
  });

  // Factory constructor لتحويل JSON إلى Service
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      priceWithOutCommission: json['priceWithOutCommission'],
      is_available: json['is_available'],
      insertedValues: json['insertedValues'],
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      customFields: json['custom_fields'] != null
          ? (json['custom_fields'] as List)
              .map((field) => CustomField.fromJson(field))
              .toList()
          : [],
      user: json['user'] != null
          ? User.fromMap(json['user'])
          : User(id: 0, name: "غير معروف"),
      category: json['category'] != null
          ? SubCategory.fromJson(json['category'])
          : null,
      quantity: json['quantity'], // جلب quantity فقط إذا كان موجودًا
    );
  }

  // تحويل Service إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'priceWithOutCommission': priceWithOutCommission,
      'is_available': is_available,
      'insertedValues': insertedValues,
      'image_urls': imageUrls ?? [],
      'custom_fields':
          customFields?.map((field) => field.toJson()).toList() ?? [],
      'user': user.toMap(),
      'category': category ?? [],
      'quantity': quantity, // تضمين quantity إذا كان غير null
    };
  }

  // تحويل Service إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'priceWithOutCommission': priceWithOutCommission,
      'is_available': is_available,
      'insertedValues': insertedValues,
      'image_urls': imageUrls ?? [],
      'custom_fields':
          customFields?.map((field) => field.toJson()).toList() ?? [],
      'user': user.toMap(),
      'category': category ?? [],
      'quantity': quantity, // تضمين quantity إذا كان غير null
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? '',
      priceWithOutCommission: map['priceWithOutCommission'] ?? '',
      is_available: map['is_available'] ?? '',
      imageUrls: map['image_urls'] != null
          ? List<String>.from(map['image_urls'])
          : null,
      customFields: map['custom_fields'] != null
          ? List<CustomField>.from(
              map['custom_fields']?.map((x) => CustomField.fromMap(x)))
          : null,
      insertedValues: map['insertedValues'],
      user: User.fromMap(map['user']),
      category:
          map['category'] != null ? SubCategory.fromMap(map['category']) : null,
      quantity: map['quantity']?.toInt(),
    );
  }
}
