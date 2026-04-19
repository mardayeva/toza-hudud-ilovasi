import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class AuthService {
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
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
      return ApiConfig.demoMode
          ? _demoDriverResponse(
              login: login,
              fullName: 'Haydovchi demo',
            )
          : null;
    } catch (_) {
      return ApiConfig.demoMode
          ? _demoDriverResponse(
              login: login,
              fullName: 'Haydovchi demo',
            )
          : null;
    }
  }

  Future<void> saveResidentProfile({
    required int tumanId,
    required String tumanName,
    required String mahalla,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_tuman_id', tumanId);
    await prefs.setString('user_tuman_name', tumanName);
    await prefs.setString('user_mahalla', mahalla);
  }

  Future<Map<String, dynamic>?> getResidentProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final tumanId = prefs.getInt('user_tuman_id');
    final tumanName = prefs.getString('user_tuman_name');
    final mahalla = prefs.getString('user_mahalla');
    if (tumanId == null || tumanName == null || mahalla == null) {
      return null;
    }
    return {
      'tuman_id': tumanId,
      'tuman_name': tumanName,
      'mahalla': mahalla,
    };
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
    await prefs.remove('user_tuman_id');
    await prefs.remove('user_tuman_name');
    await prefs.remove('user_mahalla');
  }
}
