import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:makfy_new/Models/Cart.dart';
import 'package:makfy_new/Models/Category.dart';
import 'package:makfy_new/Models/City.dart';
import 'package:makfy_new/Models/District.dart';
import 'package:makfy_new/Models/Service.dart';
import 'package:makfy_new/Models/User.dart';
import 'package:makfy_new/Models/SubCategory.dart';
import 'package:makfy_new/Models/Vacation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:geolocator/geolocator.dart';

class ApiConfig {
  // static const String apiUrl = 'http://makfy.test/api';
  static const String apiUrl = 'https://makfy.sa/api';
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await ApiConfig().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json', // Set the Accept header to expect JSON
      'Authorization': "Bearer ${token}",
    };
  }

  // Function to get the categories from the API
  static Future<List<Category>> getCategories() async {
    print(apiUrl);
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

  static Future<Category> getCategory(
      int id, double? latitude, double? longtitude) async {
    // Position position = await ApiConfig().getCurrentLocation();
    final url = (latitude == null)
        ? Uri.parse("${apiUrl}/category/${id}")
        : Uri.parse("${apiUrl}/category/${id}/${latitude}/${longtitude}");
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
      // final authHeader = await ApiConfig.getAuthHeaders();
      final response = await http.get(url);

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

  static Future<List<User>> initServices() async {
    final url = Uri.parse("${apiUrl}/service/latest_services");
    final token = await ApiConfig().getToken();
    try {
      final authHeader = await ApiConfig.getAuthHeaders();
      final response = await http.get(url, headers: authHeader);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<User> services = (jsonResponse['data'] as List)
            .map((serviceJson) => User.fromJson(serviceJson))
            .toList();
        return services;
      } else {
        // print(token);
        return throw Exception(response.statusCode);
      }
    } catch (e) {
      throw Exception("${e}");
    }
  }

  static Future<List<Cart>> customerCartList() async {
    final url = Uri.parse("${apiUrl}/cart/customer/non-paid");
    final token = await ApiConfig().getToken();
    try {
      final authHeader = await ApiConfig.getAuthHeaders();
      final response = await http.get(url, headers: authHeader);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<Cart> carts = (jsonResponse['data'] as List)
            .map((cartJson) => Cart.fromJson(cartJson))
            .toList();
        return carts;
      } else {
        return throw Exception(response.statusCode);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<List<Cart>> serviceProviderCartList() async {
    final url = Uri.parse("${apiUrl}/cart/service_provider");
    final token = await ApiConfig().getToken();
    try {
      final authHeader = await ApiConfig.getAuthHeaders();
      final response = await http.get(url, headers: authHeader);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<Cart> carts = (jsonResponse['data'] as List)
            .map((cartJson) => Cart.fromJson(cartJson))
            .toList();
        return carts;
      } else {
        return throw Exception(response.statusCode);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<List<Cart>> customerPaidCartList() async {
    final url = Uri.parse("${apiUrl}/cart/customer/paid");
    final token = await ApiConfig().getToken();
    try {
      final authHeader = await ApiConfig.getAuthHeaders();
      final response = await http.get(url, headers: authHeader);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<Cart> carts = (jsonResponse['data'] as List)
            .map((cartJson) => Cart.fromJson(cartJson))
            .toList();
        return carts;
      } else {
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

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userData['name']);
    await prefs.setString('user_email', userData['email']);
    await prefs.setInt('user_id', userData['id']);
    if (userData['id_number'] != null || userData['id_number'] != '') {
      await prefs.setInt('isServiceProvider', 1);
    }
    if (userData['id_number'] == null) {
      await prefs.setInt('isServiceProvider', 0);
    }
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
    await prefs.remove('isServiceProvider');
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
        final responseBody = await response.stream.bytesToString();
        final decodedBody = json.decode(responseBody);
        if (response.statusCode == 422) {
          final errors = decodedBody['errors'] as Map<String, dynamic>;
          String errorMessages = errors.entries
              .map((e) =>
                  "${e.value.join(", ")}") // تحويل قائمة الأخطاء إلى نصوص مفصولة بفاصلة
              .join("\n");
          return [null, 'يوجد أخطاء:\n$errorMessages'];
        } else {
          return [null, 'يوجد خلل لم يتم إنشاء الخدمة ${response.statusCode}'];
        }
      }
    } catch (e) {
      throw Exception("خطأ أثناء إرسال البيانات: $e");
    }
  }

  Future<List> updateService(Map<String, dynamic> data, int serviceId) async {
    final url = Uri.parse("${apiUrl}/service/$serviceId/update");
    final authHeader = await ApiConfig.getAuthHeaders();

    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(authHeader);

    data.forEach((key, value) {
      if (value is! File) {
        request.fields[key] = value.toString();
      }
    });

    for (var entry in data.entries) {
      if (entry.value is File) {
        final file = entry.value as File;
        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            file.path,
            filename: basename(file.path),
          ),
        );
      }
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return [
          json.decode(responseBody)['data']['id'],
          'تم تحديث الخدمة بنجاح'
        ];
      } else {
        return [null, 'يوجد خلل لم يتم تحديث الخدمة ${response.statusCode}'];
      }
    } catch (e) {
      throw Exception("خطأ أثناء إرسال البيانات: $e");
    }
  }

  Future<List> register(
      String name,
      String phone,
      String email,
      String password,
      String passwordConfirmation,
      bool? isServiceProvider,
      String? idnumber,
      String? nationality,
      String? bank,
      String? iban,
      String? order_limit_per_day,
      int? deliveryFee) async {
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
        'is_service_provider': isServiceProvider ?? null,
        'id_number': idnumber ?? null,
        'nationality': nationality ?? null,
        'bank': bank ?? null,
        'iban': iban ?? null,
        'order_limit_per_day': order_limit_per_day ?? null,
        'delivery_fee': deliveryFee ?? null,
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

  Future<List> updateProfile(
      String name,
      String phone,
      String email,
      bool? isServiceProvider,
      String? idnumber,
      String? nationality,
      String? bank,
      String? iban,
      String? order_limit_per_day,
      int? deliveryFee) async {
    final url = Uri.parse('$apiUrl/profile/update');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}' // جلب التوكن للمصادقة
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'is_service_provider': isServiceProvider,
        'id_number': idnumber,
        'nationality': nationality,
        'bank': bank,
        'iban': iban,
        'order_limit_per_day': order_limit_per_day,
        'delivery_fee': deliveryFee,
      }),
    );

    if (response.statusCode == 200) {
      // التحديث ناجح، معالجة الاستجابة حسب الحاجة
      final data = jsonDecode(response.body);
      await saveUserData(data['user']); // تحديث بيانات المستخدم
      return [true, 'Profile updated successfully'];
    } else {
      // فشل التحديث، عرض رسالة خطأ
      print('Profile update failed: ${response.body}');
      return [false, jsonDecode(response.body)];
    }
  }

  static Future<Map<String, dynamic>> updateCart(Map<int, dynamic> data,
      Cart? cart, String datatimestamp, bool? delivery_is_required) async {
    final url = (cart != null)
        ? Uri.parse('$apiUrl/cart/update')
        : Uri.parse('$apiUrl/cart/create');
    final authHeader = await ApiConfig.getAuthHeaders();
    final formattedData =
        data.map((key, value) => MapEntry(key.toString(), value.toString()));
    formattedData['service_datetime'] = datatimestamp;
    formattedData['delivery_is_required'] =
        delivery_is_required == true ? "1" : "0";
    final response = await http.post(
      url, // Ensure this endpoint is correct
      headers: {...authHeader, 'Content-Type': 'application/json'},
      body: jsonEncode(formattedData),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> checkPaymentID(String paymentID) async {
    final url = Uri.parse('$apiUrl/cart/checkpayment');
    final authHeader = await ApiConfig.getAuthHeaders();
    final response = await http.post(url, // Ensure this endpoint is correct
        headers: {...authHeader, 'Content-Type': 'application/json'},
        body: jsonEncode({'id': paymentID}));
    return jsonDecode(response.body);
  }

  static Future<List<City>> getCities() async {
    final url = Uri.parse("${apiUrl}/area/cities");
    final authHeader = await ApiConfig.getAuthHeaders();
    final response = await http.post(
      url,
      headers: {...authHeader, 'Content-Type': 'application/json'},
    );

    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // استخراج قائمة المدن من المفتاح "data"
        List<City> cities = (jsonResponse['data'] as List)
            .map((cityJson) => City.fromMap(cityJson))
            .toList();

        return cities;
      } else {
        throw Exception("Failed to load cities: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error parsing cities: $e");
    }
  }

  static Future<City> getDistricts(int city_id) async {
    final url = Uri.parse("${apiUrl}/area/districts/${city_id}");
    final authHeader = await ApiConfig.getAuthHeaders();
    final response = await http.post(
      url, // Ensure this endpoint is correct
      headers: {...authHeader, 'Content-Type': 'application/json'},
    );
    try {
      if (response.statusCode == 200) {
        City districts = City.fromMap(json.decode(response.body)['data']);
        return districts;
      } else {
        return throw Exception(response.statusCode);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> rate(int cart, double rating) async {
    final url = Uri.parse('$apiUrl/cart/rate/$cart');
    final authHeader = await ApiConfig.getAuthHeaders();
    final response = await http.post(
      url, // Ensure this endpoint is correct
      headers: {...authHeader, 'Content-Type': 'application/json'},
      body: jsonEncode({'rating': rating}),
    );
    // print(response.body);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> makeCartOnProgress(
      int cartId, int otp) async {
    final url = Uri.parse('$apiUrl/cart/makeCartOnProgress/$cartId');
    final authHeader =
        await ApiConfig.getAuthHeaders(); // جلب الـ headers للتوثيق

    final response = await http.post(
      url,
      headers: {
        ...authHeader,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'otp': otp}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // يعيد الاستجابة كـ Map
    } else {
      throw Exception(
          'Failed to make cart on progress'); // إذا فشلت العملية، يتم إطلاق خطأ
    }
  }

  static Future<Map<String, dynamic>> makeCartComplete(int cartId) async {
    final url = Uri.parse('$apiUrl/cart/makeCartComplete/$cartId');
    final authHeader =
        await ApiConfig.getAuthHeaders(); // جلب الـ headers للتوثيق

    final response = await http.post(url, headers: {
      ...authHeader,
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // يعيد الاستجابة كـ Map
    } else {
      throw Exception(
          'Failed to make cart on progress'); // إذا فشلت العملية، يتم إطلاق خطأ
    }
  }

  static Future<bool> addDistrict(int districtId) async {
    final url = Uri.parse("${apiUrl}/area/add/$districtId");
    final authHeader = await ApiConfig.getAuthHeaders();

    try {
      final response = await http.post(
        url,
        headers: {...authHeader, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true; // إذا تمت إضافة الحي بنجاح
      } else {
        print("Failed to add district. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error adding district: $e");
      return false;
    }
  }

  static Future<List<District>> getUserDistricts() async {
    final url = Uri.parse("${apiUrl}/user/districts");
    final authHeader = await ApiConfig.getAuthHeaders();

    try {
      final response = await http.get(
        url,
        headers: {...authHeader, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // تأكد من أن الاستجابة يتم فك تشفيرها بشكل صحيح
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // تحويل البيانات إلى قائمة من الكائنات District
        List<District> districts = (jsonResponse['data'] as List)
            .map((districtJson) => District.fromMap(districtJson))
            .toList();

        return districts;
      } else {
        throw Exception(
            "Failed to load user districts. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching user districts: $e");
    }
  }

// دالة لحذف حي معين من الأحياء الخاصة بالمستخدم
  static Future<bool> deleteUserDistrict(int districtId) async {
    final url = Uri.parse("${apiUrl}/user/districts/$districtId");
    final authHeader = await ApiConfig.getAuthHeaders();

    try {
      final response = await http.delete(
        url,
        headers: {...authHeader, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true; // حذف الحي بنجاح
      } else {
        print("Failed to delete district. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error deleting district: $e");
      return false;
    }
  }

  static Future<bool> changeServiceAvailability(int serviceId) async {
    final url = Uri.parse("${apiUrl}/service/availablity/$serviceId");
    try {
      // احصل على الهيدر الخاص بالمصادقة
      final authHeader = await ApiConfig.getAuthHeaders();

      // أرسل الطلب
      final response = await http.post(
        url,
        headers: authHeader,
      );

      // تحقق من نجاح العملية
      if (response.statusCode == 200) {
        print("Service availability updated successfully.");
        return true; // إذا نجحت العملية
      } else if (response.statusCode == 403) {
        print("Permission denied to change availability.");
        return false; // إذا كان المستخدم لا يملك الصلاحية
      } else {
        print(
            "Failed to update availability. Status code: ${response.statusCode}");
        return false; // فشل العملية لأي سبب آخر
      }
    } catch (e) {
      print("Error changing service availability: $e");
      return false; // حدث خطأ أثناء الاتصال
    }
  }

  static Future<String> getUserDues() async {
    final url = Uri.parse('$apiUrl/user/dues');
    final headers = await getAuthHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['dues'];
      } else {
        throw Exception(
            'Failed to fetch dues. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching dues: $e');
    }
  }

  static Future<Category> searchServices(Map<String, dynamic> filters,
      double? latitude, double? longtitude) async {
    final url = (latitude == null)
        ? Uri.parse("${apiUrl}/category/filter")
        : Uri.parse("${apiUrl}/category/filter/${latitude}/${longtitude}");
    try {
      final authHeader = await ApiConfig.getAuthHeaders();
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(filters),
      );
      // print(jsonEncode(filters));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

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
        print("HTTP Error: ${response.body}");
        throw Exception(
            'Failed to filter services. Status code: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to filter services. Error: $e');
    }
  }

  static Future<List<dynamic>> filterServiceProviders(
      Map<String, dynamic> filters) async {
    final url = Uri.parse("$apiUrl/category/filter");
    final authHeader = await ApiConfig.getAuthHeaders();
    final response = await http.post(
      url,
      headers: {...authHeader, 'Content-Type': 'application/json'},
      body: jsonEncode(filters),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data'];
    } else {
      throw Exception(
          "Failed to filter service providers: ${response.statusCode}");
    }
  }

  // جلب بيانات الكارت المحدثة
  static Future<Cart> getCart(int cartId) async {
    final url = Uri.parse(
        '$apiUrl/cart/show/$cartId'); // استبدل المسار حسب API الخاص بك
    final headers = await getAuthHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
          return Cart.fromJson(jsonResponse['data']);
        } else {
          throw Exception("Invalid response format or no data found");
        }
      } else {
        throw Exception(
            "Failed to fetch updated cart. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching updated cart: $e");
    }
  }

  static Future<String> checkAvailableTime(
      int userID, String date, String time) async {
    final url = Uri.parse(
        '$apiUrl/user/checkTime/$userID'); // استبدل المسار حسب API الخاص بك
    // final headers = await getAuthHeaders();
    print('$apiUrl/user/checkTime/$userID');
    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"date": date, "time": time}));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
          print(jsonResponse['data']['datetimestamp']);
          return jsonResponse['data']['datetimestamp'];
        } else {
          throw Exception("Invalid response format or no data found");
        }
      } else {
        throw Exception(
            "Failed to fetch updated cart. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching updated cart: $e");
    }
  }

  static Future<bool> deleteCart(int cartId) async {
    final url = Uri.parse("$apiUrl/cart/delete/$cartId");
    final authHeader = await ApiConfig.getAuthHeaders();

    try {
      final response = await http.delete(
        url,
        headers: {
          ...authHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // السلة تم حذفها بنجاح
        return true;
      } else {
        // فشل حذف السلة، عرض رسالة أو معالجة الخطأ
        print("Failed to delete cart. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      // حدث خطأ أثناء الاتصال بالـ API
      print("Error deleting cart: $e");
      return false;
    }
  }

  static Future<bool> sendResetPasswordEmail(String email) async {
    final url = Uri.parse("$apiUrl/password/email");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        print("Reset password link sent successfully.");
        return true; // إذا تم إرسال الرابط بنجاح
      } else {
        print(
            "Failed to send reset password link. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error sending reset password link: $e");
      return false;
    }
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // تحقق من أن خدمات الموقع مفعلة
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Position(
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 0.0,
        altitudeAccuracy: 0.0,
        altitude: 0.0,
        headingAccuracy: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        timestamp: DateTime.now(),
      );
      // throw Exception('خدمات الموقع معطلة.');
    }

    // تحقق من أذونات الموقع
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Position(
          latitude: 0.0,
          longitude: 0.0,
          accuracy: 0.0,
          altitudeAccuracy: 0.0,
          altitude: 0.0,
          headingAccuracy: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          timestamp: DateTime.now(),
        );
        // throw Exception('تم رفض أذونات الموقع.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Position(
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 0.0,
        altitudeAccuracy: 0.0,
        altitude: 0.0,
        headingAccuracy: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        timestamp: DateTime.now(),
      );
      // throw Exception('تم رفض أذونات الموقع بشكل دائم.');
    }

    // احصل على الموقع الحالي
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  static Future<District?> findArea(double latitude, double longitude) async {
    final url = Uri.parse("$apiUrl/area/find/$latitude/$longitude");
    final authHeader = await ApiConfig.getAuthHeaders();

    try {
      // إرسال الطلب
      final response = await http.post(
        url,
        headers: {
          ...authHeader,
          'Content-Type': 'application/json',
        },
      );

      // التحقق من نجاح الطلب
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // التحقق من وجود البيانات المطلوبة
        if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
          return District.fromMap(jsonResponse['data']);
        } else {
          throw Exception("Invalid response format: Missing 'data' field.");
        }
      } else {
        throw Exception(
            "Failed to find area. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // التعامل مع الأخطاء
      throw Exception("Error finding area: $e");
    }
  }

  static Future<bool> updateUserLocation() async {
    try {
      // الحصول على الموقع الحالي
      final position = await ApiConfig().getCurrentLocation();
      final latitude = position.latitude;
      final longitude = position.longitude;

      // استدعاء API لإرسال الطول والعرض
      final url = Uri.parse("${apiUrl}/user/updateOrCreateLocation");
      final authHeader = await ApiConfig.getAuthHeaders();

      final response = await http.post(
        url,
        headers: {
          ...authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        print("Location updated successfully.");
        return true;
      } else {
        print("Failed to update location. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error updating user location: $e");
      return false;
    }
  }

  static Future<bool> updateUserWorkingTime(
      String startTime, String EndTime) async {
    try {
      // استدعاء API لإرسال الطول والعرض
      final url = Uri.parse("${apiUrl}/user/updateWorkingHours");
      final authHeader = await ApiConfig.getAuthHeaders();

      final response = await http.post(
        url,
        headers: {
          ...authHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'start_time': startTime,
          'end_time': EndTime,
        }),
      );

      if (response.statusCode == 200) {
        print("Time updated successfully.");
        return true;
      } else {
        print("Failed to update Time. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error updating user Time: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUserWorkingHours() async {
    final url = Uri.parse("$apiUrl/user/getWorkingHours");
    final authHeader = await getAuthHeaders();

    try {
      final response = await http.get(
        url,
        headers: authHeader,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['data']; // يحتوي على latitude و longitude
      } else {
        throw Exception(
            "Failed to fetch working time. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching user workingTIme: $e");
    }
  }

  static Future<bool> deleteUser() async {
    try {
      // استدعاء API لإرسال الطول والعرض
      final url = Uri.parse("${apiUrl}/user/user_delete");
      final authHeader = await ApiConfig.getAuthHeaders();

      final response = await http.post(
        url,
        headers: {
          ...authHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("Time updated successfully.");
        return true;
      } else {
        print("Failed to update Time. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error updating user Time: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUserLocation() async {
    final url = Uri.parse("$apiUrl/user/getLocation");
    final authHeader = await getAuthHeaders();

    try {
      final response = await http.get(
        url,
        headers: authHeader,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['data']; // يحتوي على latitude و longitude
      } else {
        throw Exception(
            "Failed to fetch location. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching user location: $e");
    }
  }

  static Future<Vacation?> createVacation(Vacation vacation) async {
    final url = Uri.parse("$apiUrl/user/vacations");
    final authHeader = await ApiConfig.getAuthHeaders();

    try {
      final response = await http.post(
        url,
        headers: {...authHeader, 'Content-Type': 'application/json'},
        body: jsonEncode(vacation.toMap()), // تحويل الكائن إلى Map
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body)['data'];
        return Vacation.fromMap(data); // تحويل الاستجابة إلى كائن Vacation
      } else {
        print("Failed to create vacation. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error creating vacation: $e");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getVacations() async {
    final url = Uri.parse("$apiUrl/user/vacations");
    final authHeader = await ApiConfig.getAuthHeaders();

    try {
      final response = await http.get(url, headers: authHeader);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        } else {
          throw Exception(
              "Invalid response format: 'data' is missing or invalid.");
        }
      } else {
        throw Exception(
            "Failed to fetch vacations. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching vacations: $e");
    }
  }

  static Future<Vacation?> updateVacation(
      int vacationId, Vacation updatedVacation) async {
    final url = Uri.parse("$apiUrl/user/vacations/$vacationId");
    final authHeader = await ApiConfig.getAuthHeaders();

    try {
      final response = await http.put(
        url,
        headers: {...authHeader, 'Content-Type': 'application/json'},
        body: updatedVacation.toJson(), // تحويل Vacation إلى JSON
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return Vacation.fromMap(data); // إرجاع Vacation بعد التحديث
      } else {
        print("Failed to update vacation. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error updating vacation: $e");
      return null;
    }
  }

  static Future<bool> deleteVacation(int vacationId) async {
    final url = Uri.parse("$apiUrl/user/vacations/$vacationId");
    final authHeader = await ApiConfig.getAuthHeaders();

    try {
      final response = await http.delete(
        url,
        headers: {
          ...authHeader,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("Vacation deleted successfully.");
        return true;
      } else {
        print("Failed to delete vacation. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error deleting vacation: $e");
      return false;
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
