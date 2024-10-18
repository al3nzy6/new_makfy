import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:makfy_new/Models/Category.dart';
import 'package:makfy_new/Models/Service.dart';
import 'package:makfy_new/Models/User.dart';
import 'package:makfy_new/Models/fieldSection.dart';
import 'package:makfy_new/Models/SubCategory.dart';
import 'package:makfy_new/Screens/subsectionPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

class ApiConfig {
  static const String apiUrl = 'https://makfy.abdullah-alanazi.sa/api';
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await ApiConfig().getToken();
    return {
      'Accept': 'application/json', // Set the Accept header to expect JSON
      'Authorization': "Bearer ${token}",
    };
  }

  // Function to get the categories from the API
  static Future<List<Category>> getCategories() async {
    final url = Uri.parse("$apiUrl/categories");
    final token = await ApiConfig().getToken();

    try {
      // Make an HTTP GET request
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json', // Set the Accept header to expect JSON
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON response body
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Convert the data FieldSection to a list of Category objects
        CategoryResponse categoryResponse =
            CategoryResponse.fromJson(jsonResponse);
        // Return the list of categories
        return categoryResponse.data;
      } else {
        // If the API returns a response code other than 200, throw an error
        throw Exception(
            'Failed to load categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Catch and print any error that occurs during the request
      print('Error: $e');
      throw Exception('Error fetching categories: $e');
    }
  }

  static Future<Category> getCategory(int id) async {
    final url = Uri.parse("${apiUrl}/category/$id");
    try {
      final authHeader = await ApiConfig.getAuthHeaders();
      final response = await http.get(url, headers: authHeader);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // عرض الاستجابة للتحقق من محتواها
        // print("Response body: ${response.body}");

        // التحقق من أن 'data' موجودة وليست null
        if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
          // التحقق من أن jsonResponse['data'] هو Map
          if (jsonResponse['data'] is Map<String, dynamic>) {
            Category category = Category.fromJson(jsonResponse['data']);
            return category;
          } else {
            throw Exception(
                'Invalid data type: ${jsonResponse['data'].runtimeType}');
          }
        } else {
          throw Exception(
              'Invalid response format: Missing "data" field or is null');
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
        throw Exception(
            'Failed to load category. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load category. Error: $e');
    }
  }

  static Future<User> getUserProfile(int id) async {
    final url = Uri.parse("${apiUrl}/user/$id/profile");
    try {
      final authHeader = await ApiConfig.getAuthHeaders();
      final response = await http.get(url, headers: authHeader);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // عرض الاستجابة للتحقق من محتواها
        // print("Response body: ${response.body}");

        // التحقق من أن 'data' موجودة وليست null
        if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
          // التحقق من أن jsonResponse['data'] هو Map
          if (jsonResponse['data'] is Map<String, dynamic>) {
            User services = User.fromJson(jsonResponse['data']);
            return services;
          } else {
            throw Exception(
                'Invalid data type: ${jsonResponse['data'].runtimeType}');
          }
        } else {
          throw Exception(
              'Invalid response format: Missing "data" field or is null');
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
        throw Exception(
            'Failed to load category. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load category. Error: $e');
    }
  }

  static Future<Service> getService(int id) async {
    final url = Uri.parse('${apiUrl}/service/$id');
    final authHeader = await ApiConfig.getAuthHeaders();

    try {
      final response = await http.get(url, headers: authHeader);

      if (response.statusCode == 200) {
        // Decode the JSON response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if 'data' exists and is not null before creating the Service object
        if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
          return Service.fromJson(jsonResponse['data']);
        } else {
          throw Exception(
              'Invalid response format: Missing or null "data" field');
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
        throw Exception(
            "Failed to load service. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception('Failed to load service. Error: $e');
    }
  }

  static Future<List<Service>> initServices() async {
    final url = Uri.parse("${apiUrl}/service/latest_services");
    final token = await ApiConfig().getToken();
    try {
      final authHeader = await ApiConfig.getAuthHeaders();
      final response = await http.get(url, headers: authHeader);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<Service> services = (jsonResponse['data'] as List)
            .map((serviceJson) => Service.fromJson(serviceJson))
            .toList();
        return services;
      } else {
        print(token);
        return throw Exception(response.statusCode);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/login'), // Ensure this endpoint is correct
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token =
          data['access_token']; // Ensure this matches the key for your token

      if (token != null) {
        await saveToken(token);
        await saveUserData(data['user']); // Save user details if needed
        return [true, 'ok']; // Login successful
      }
    } else {
      // Log the error response for debugging
      return [false, jsonDecode(response.body)['message']];
    }

    return [false, 'error']; // Login failed
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userData['name']);
    await prefs.setString('user_email', userData['email']);
    await prefs.setInt('user_id', userData['id']);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
  }

  // services

  Future<List> createService(Map<String, dynamic> data) async {
    final url = Uri.parse("${apiUrl}/service/create");
    final authHeader = await ApiConfig.getAuthHeaders();

    // قم بإنشاء MultipartRequest لرفع الملفات
    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(authHeader);

    // قم بإضافة البيانات النصية (غير الصور)
    data.forEach((key, value) {
      if (value is! File) {
        request.fields[key] = value.toString();
      }
    });

    // قم بإضافة الملفات إلى الطلب
    for (var entry in data.entries) {
      if (entry.value is File) {
        final file = entry.value as File;
        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key, // اسم الحقل
            file.path,
            filename: basename(file.path), // اسم الملف
          ),
        );
      }
    }

    // إرسال الطلب
    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final id = json.decode(responseBody)['data']['id'];
        return [id, 'تم إنشاء الخدمة'];
      } else {
        return [null, 'يوجد خلل لم يتم إنشاء الخدمة ${response.statusCode}'];
      }
    } catch (e) {
      throw Exception("خطأ أثناء إرسال البيانات: $e");
    }
  }

  Future<List> register(String name, String phone, String email,
      String password, String passwordConfirmation) async {
    final url = Uri.parse('$apiUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password_confirmation': passwordConfirmation,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // التسجيل ناجح، قم بمعالجة الاستجابة حسب احتياجاتك
      final data = jsonDecode(response.body);
      // يمكنك تخزين التوكن أو معلومات المستخدم هنا إذا لزم الأمر
      if (data['access_token'] != null) {
        await saveToken(data['access_token']);
        await saveUserData(data['user']); // S
      }
      return [true, 'Registration completed'];
    } else {
      // التسجيل فشل، قم بعرض رسالة خطأ أو معالجة الخطأ
      print('Registration failed: ${response.body}');
      return [false, jsonDecode(response.body)];
    }
  }
  // static Future<List<FieldSection>> getFieldSections(int category_id) async {
  //   final url = Uri.parse("${apiUrl}/category/${category_id}");
  //   try {
  //     final response = await http.get(url, headers: {
  //       'Accept': 'application/json', // Set the Accept header to expect JSON
  //     });
  //     if (response.statusCode == 200) {
  //       // Parse the JSON response body
  //       final Map<String, dynamic> jsonResponse =
  //           json.decode(response.body)['data']['Fields'];

  //       // Convert the data FieldSection to a list of Category objects
  //       List<FieldSection> fields = jsonResponse;

  //       // Return the list of categories
  //       return fields;
  //     } else {
  //       // If the API returns a response code other than 200, throw an error
  //       throw Exception(
  //           'Failed to load categories. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to load categories. Status code: ${e}');
  //   }
  // }
}
