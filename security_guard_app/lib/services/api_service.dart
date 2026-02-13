import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';

class ApiService extends ChangeNotifier {
  String? _token;
  List<AppUser> _cachedUsers = [];
  
  bool get isAuthenticated => _token != null;
  List<AppUser> get users => List.unmodifiable(_cachedUsers);
  String? get token => _token;

  http.Client _createClient() {
    return http.Client();
  }

  Map<String, String> _headers({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Login and get JWT token
  Future<bool> login(String email, String password) async {
    try {
      debugPrint('🔐 Attempting login to: ${ApiConfig.baseUrl}/Auth/login');
      debugPrint('🔐 Email: $email');
      
      final client = _createClient();
      final uri = Uri.parse('${ApiConfig.baseUrl}/Auth/login');
      debugPrint('🔐 Full URL: $uri');
      
      final response = await client
          .post(
            uri,
            headers: _headers(includeAuth: false),
            body: jsonEncode({'Email': email, 'Password': password}),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      debugPrint('🔐 Response status: ${response.statusCode}');
      debugPrint('🔐 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        debugPrint('✅ Login successful! Token received.');
        notifyListeners();
        return true;
      }
      
      debugPrint('❌ Login failed: Status ${response.statusCode}');
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ Login error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return false;
    }
  }

  // Fetch all users
  Future<List<AppUser>> fetchUsers() async {
    try {
      final client = _createClient();
      final response = await client
          .get(
            Uri.parse('${ApiConfig.baseUrl}/Users'),
            headers: _headers(),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _cachedUsers = data.map((json) => _userFromJson(json)).toList();
        notifyListeners();
        return _cachedUsers;
      }
      return [];
    } catch (e) {
      debugPrint('Fetch users error: $e');
      return [];
    }
  }

  // Create user
  Future<AppUser?> createUser({
    required String name,
    required String email,
    required int activeDays,
  }) async {
    try {
      final client = _createClient();
      final response = await client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/Users'),
            headers: _headers(),
            body: jsonEncode({
              'Name': name,
              'Email': email,
              'ActiveDays': activeDays,
            }),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final user = _userFromJson(json);
        _cachedUsers.insert(0, user);
        notifyListeners();
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Create user error: $e');
      return null;
    }
  }

  // Block user
  Future<bool> blockUser(String userId) async {
    try {
      final client = _createClient();
      final response = await client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/Users/$userId/block'),
            headers: _headers(),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 204) {
        final idx = _cachedUsers.indexWhere((u) => u.id == userId);
        if (idx != -1) {
          _cachedUsers[idx] = _cachedUsers[idx].copyWith(isBlocked: true);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Block user error: $e');
      return false;
    }
  }

  // Unblock user
  Future<bool> unblockUser(String userId) async {
    try {
      final client = _createClient();
      final response = await client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/Users/$userId/unblock'),
            headers: _headers(),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 204) {
        final idx = _cachedUsers.indexWhere((u) => u.id == userId);
        if (idx != -1) {
          _cachedUsers[idx] = _cachedUsers[idx].copyWith(isBlocked: false);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Unblock user error: $e');
      return false;
    }
  }

  // Fetch locations
  Future<List<Map<String, dynamic>>> fetchLocations() async {
    try {
      final client = _createClient();
      final response = await client
          .get(
            Uri.parse('${ApiConfig.baseUrl}/Locations'),
            headers: _headers(),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      debugPrint('Fetch locations error: $e');
      return [];
    }
  }

  // Create location
  Future<Map<String, dynamic>?> createLocation({
    required String name,
    String? description,
  }) async {
    try {
      final client = _createClient();
      final response = await client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/Locations'),
            headers: _headers(),
            body: jsonEncode({
              'Name': name,
              'Description': description,
            }),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Create location error: $e');
      return null;
    }
  }

  // Get QR code URL for a location
  String getQrCodeUrl(int locationId) {
    return '${ApiConfig.baseUrl}/Locations/$locationId/qrcode';
  }

  // Fetch reports
  Future<List<Map<String, dynamic>>> fetchReports() async {
    try {
      debugPrint('📡 API: Fetching reports from ${ApiConfig.baseUrl}/Reports');
      debugPrint('📡 API: Token present: ${_token != null}');
      
      final client = _createClient();
      final response = await client
          .get(
            Uri.parse('${ApiConfig.baseUrl}/Reports'),
            headers: _headers(),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      debugPrint('📡 API: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        debugPrint('📡 API: Successfully fetched ${data.length} reports');
        return data;
      }
      
      debugPrint('❌ API: Failed with status ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('❌ API: Error fetching reports: $e');
      rethrow;
    }
  }

  // Create report
  Future<Map<String, dynamic>?> createReport({
    int? userId,
    int? locationId,
    required String type,
    String? description,
  }) async {
    try {
      final client = _createClient();
      final response = await client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/Reports'),
            headers: _headers(),
            body: jsonEncode({
              'UserId': userId,
              'LocationId': locationId,
              'Type': type,
              'Description': description,
            }),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Create report error: $e');
      return null;
    }
  }

  // Get current user info
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final client = _createClient();
      final response = await client
          .get(
            Uri.parse('${ApiConfig.baseUrl}/Users/me'),
            headers: _headers(),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get current user error: $e');
      return null;
    }
  }

  // Record attendance (check-in/check-out)
  Future<Map<String, dynamic>> recordAttendance(String qrData) async {
    try {
      debugPrint('📍 Recording attendance for QR: $qrData');
      final client = _createClient();
      final response = await client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/Attendance'),
            headers: _headers(),
            body: jsonEncode({
              'QRData': qrData,
              'Timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      debugPrint('📍 Attendance response: ${response.statusCode}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Attendance recorded successfully');
        return data;
      }
      
      throw Exception('Failed to record attendance: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Attendance error: $e');
      rethrow;
    }
  }

  // Submit report (Activity or Incident)
  Future<Map<String, dynamic>> submitReport(Map<String, dynamic> reportData) async {
    try {
      debugPrint('📝 Submitting report: ${reportData['type']}');
      final client = _createClient();
      final response = await client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/Reports'),
            headers: _headers(),
            body: jsonEncode(reportData),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      debugPrint('📝 Report response: ${response.statusCode}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Report submitted successfully');
        return data;
      }
      
      throw Exception('Failed to submit report: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Report submission error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<bool> resetPassword(String currentPassword, String newPassword) async {
    try {
      debugPrint('🔒 Resetting password');
      final client = _createClient();
      final response = await client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/Users/reset-password'),
            headers: _headers(),
            body: jsonEncode({
              'CurrentPassword': currentPassword,
              'NewPassword': newPassword,
            }),
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      debugPrint('🔒 Password reset response: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Password reset successful');
        return true;
      }
      
      throw Exception('Failed to reset password: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Password reset error: $e');
      rethrow;
    }
  }

  // Logout
  void logout() {
    _token = null;
    _cachedUsers.clear();
    notifyListeners();
  }

  // Helper to convert JSON to AppUser
  AppUser _userFromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isBlocked: json['isBlocked'] ?? false,
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'])
          : null,
    );
  }
}
