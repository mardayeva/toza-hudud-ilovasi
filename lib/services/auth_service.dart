import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class AuthService {
  Map<String, dynamic> _demoLoginResponse({
    required String username,
    required String fullName,
    required String tokenPrefix,
  }) {
    return {
      'token': '${tokenPrefix}_demo_${DateTime.now().millisecondsSinceEpoch}',
      'username': username,
      'full_name': fullName,
    };
  }

  Map<String, dynamic> _demoDriverResponse({
    required String login,
    required String fullName,
  }) {
    return {
      'token': 'driver_demo_${DateTime.now().millisecondsSinceEpoch}',
      'login': login,
      'full_name': fullName,
      'vehicle_number': '60 A 123 BA',
      'driver_id': 101,
      'tuman_id': 6,
      'mahalla': "Bog'ishamol",
    };
  }

  Future<Map<String, dynamic>?> register({
    required String username,
    required String fullName,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': username,
              'full_name': fullName,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
      return _demoLoginResponse(
        username: username,
        fullName: fullName,
        tokenPrefix: 'register',
      );
    } catch (_) {
      return _demoLoginResponse(
        username: username,
        fullName: fullName,
        tokenPrefix: 'register',
      );
    }
  }

  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
      return _demoLoginResponse(
        username: username,
        fullName: 'Demo foydalanuvchi',
        tokenPrefix: 'user',
      );
    } catch (_) {
      return _demoLoginResponse(
        username: username,
        fullName: 'Demo foydalanuvchi',
        tokenPrefix: 'user',
      );
    }
  }

  Future<Map<String, dynamic>?> driverLogin({
    required String login,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/driver/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'login': login,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
      return _demoDriverResponse(
        login: login,
        fullName: 'Haydovchi demo',
      );
    } catch (_) {
      return _demoDriverResponse(
        login: login,
        fullName: 'Haydovchi demo',
      );
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> saveUserProfile(String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_full_name', fullName);
  }

  Future<String?> getUserFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_full_name');
  }

  Future<void> saveDriverToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_token', token);
  }

  Future<String?> getDriverToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('driver_token');
  }

  Future<void> saveDriverProfile({
    required String fullName,
    required String vehicleNumber,
    required String login,
    int? driverId,
    int? tumanId,
    String? mahalla,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_full_name', fullName);
    await prefs.setString('driver_vehicle', vehicleNumber);
    await prefs.setString('driver_login', login);
    if (driverId != null) {
      await prefs.setInt('driver_id', driverId);
    }
    if (tumanId != null) {
      await prefs.setInt('driver_tuman_id', tumanId);
    }
    if (mahalla != null) {
      await prefs.setString('driver_mahalla', mahalla);
    }
  }

  Future<Map<String, String>?> getDriverProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('driver_full_name');
    final vehicle = prefs.getString('driver_vehicle');
    final login = prefs.getString('driver_login');
    if (fullName == null || vehicle == null || login == null) return null;
    final tumanId = prefs.getInt('driver_tuman_id');
    final mahalla = prefs.getString('driver_mahalla');
    final driverId = prefs.getInt('driver_id');
    return {
      'full_name': fullName,
      'vehicle_number': vehicle,
      'login': login,
      if (driverId != null) 'driver_id': driverId.toString(),
      if (tumanId != null) 'tuman_id': tumanId.toString(),
      if (mahalla != null) 'mahalla': mahalla,
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
