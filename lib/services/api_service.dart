import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/models.dart';

// ==================== API CONFIG ====================
class ApiConfig {
  static const bool demoMode = true;

  static const String devServerIp = '192.168.100.150';

  static String get baseUrl =>
      kIsWeb ? 'http://127.0.0.1:8000/v1' : 'http://$devServerIp:8000/v1';

  static String get wsUrl =>
      kIsWeb ? 'ws://127.0.0.1:8000/ws' : 'ws://$devServerIp:8000/ws';

  static const String myGovAuthUrl =
      'https://sso.egov.uz/sso/oauth/Authorization.do';
  static const String myGovTokenUrl = 'https://sso.egov.uz/sso/oauth/token';
  static const String myGovClientId = 'chiqindi_nav_client';
  static const String redirectUri = 'chiqindinav://auth/callback';
}

// ==================== JADVAL API ====================
class JadvalService {
  final http.Client _client;
  JadvalService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<JadvalItem>> getJadval({
    required int tumanId,
    required String mahallaNomi,
    int? driverId,
  }) async {
    if (ApiConfig.demoMode) {
      return _demoJadval(mahallaNomi);
    }

    final String url = driverId != null
        ? '${ApiConfig.baseUrl}/jadval?driver_id=$driverId'
        : '${ApiConfig.baseUrl}/jadval?tuman_id=$tumanId&mahalla=${Uri.encodeComponent(mahallaNomi)}';

    try {
      final res = await _client
          .get(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded is Map<String, dynamic>) {
          final data = decoded['data'];
          if (data is List) {
            return data
                .whereType<Map>()
                .map((e) => _parseJadval(Map<String, dynamic>.from(e)))
                .toList();
          }
        }
      }
    } catch (_) {}

    return _demoJadval(mahallaNomi);
  }

  JadvalItem _parseJadval(Map<String, dynamic> e) => JadvalItem(
        id: e['id'].toString(),
        mahallaNomi: (e['mahalla'] ?? '').toString(),
        tumanNomi: (e['tuman'] ?? '').toString(),
        sana: DateTime.parse((e['sana'] ?? DateTime.now().toIso8601String()).toString()),
        boshlanish: (e['boshlanish'] ?? '09:00').toString(),
        tugash: (e['tugash'] ?? '10:30').toString(),
        holat: _parseHolat((e['holat'] ?? 'bugun').toString()),
        driverId: e['driver_id'] is int ? e['driver_id'] as int : int.tryParse('${e['driver_id']}'),
      );

  JadvalHolat _parseHolat(String s) {
    switch (s) {
      case 'keladi':
        return JadvalHolat.keladi;
      case 'bugun':
        return JadvalHolat.bugun;
      case 'tugadi':
        return JadvalHolat.tugadi;
      default:
        return JadvalHolat.bekor;
    }
  }

  List<JadvalItem> _demoJadval(String mahalla) {
    final now = DateTime.now();
    return [
      JadvalItem(
        id: '1',
        mahallaNomi: mahalla,
        tumanNomi: 'Surxondaryo demo',
        sana: now,
        boshlanish: '09:00',
        tugash: '10:30',
        holat: JadvalHolat.bugun,
      ),
      JadvalItem(
        id: '2',
        mahallaNomi: mahalla,
        tumanNomi: 'Surxondaryo demo',
        sana: now.add(const Duration(days: 2)),
        boshlanish: '08:30',
        tugash: '10:00',
        holat: JadvalHolat.keladi,
      ),
      JadvalItem(
        id: '3',
        mahallaNomi: mahalla,
        tumanNomi: 'Surxondaryo demo',
        sana: now.add(const Duration(days: 4)),
        boshlanish: '09:00',
        tugash: '10:30',
        holat: JadvalHolat.keladi,
      ),
    ];
  }
}

// ==================== MASHINA KUZATISH (WebSocket) ====================
class MashinaKuzatishService {
  WebSocketChannel? _channel;
  Timer? _demoTimer;
  final void Function(MashinaJoylashuv) onUpdate;

  MashinaKuzatishService({required this.onUpdate});

  void boshlash({required int tumanId, required String mahallaNomi}) {
    try {
      if (_channel != null) return;

      if (ApiConfig.demoMode) {
        _demoBoshlash();
        return;
      }

      _channel = WebSocketChannel.connect(
        Uri.parse(
          '${ApiConfig.wsUrl}/mashina?tuman_id=$tumanId'
          '&mahalla=${Uri.encodeComponent(mahallaNomi)}',
        ),
      );
      _channel!.stream.listen(
        (data) {
          final m = json.decode(data);
          onUpdate(MashinaJoylashuv(
            lat: (m['lat'] as num).toDouble(),
            lon: (m['lon'] as num).toDouble(),
            driverIsm: (m['driver'] ?? '').toString(),
            mashinaRaqami: (m['raqam'] ?? '').toString(),
            etaMinut: (m['eta'] as num?)?.toInt() ?? 0,
            joriyMahalla: (m['joriy_mahalla'] ?? '').toString(),
          ));
        },
        onError: (_) => _demoBoshlash(),
      );
    } catch (_) {
      _demoBoshlash();
    }
  }

  void _demoBoshlash() {
    _demoTimer?.cancel();
    _demoTimer = Timer(const Duration(seconds: 2), () {
      onUpdate(const MashinaJoylashuv(
        lat: 37.224,
        lon: 67.278,
        driverIsm: 'Alisher Karimov',
        mashinaRaqami: '60 A 123 BA',
        etaMinut: 25,
        joriyMahalla: "Bog'ishamol",
      ));
    });
  }

  void toxtatish() {
    _demoTimer?.cancel();
    _demoTimer = null;
    _channel?.sink.close();
    _channel = null;
  }
}

// ==================== JADVAL REALTIME (WebSocket) ====================
class JadvalRealtimeService {
  WebSocketChannel? _channel;
  final VoidCallback onUpdate;

  JadvalRealtimeService({required this.onUpdate});

  void boshlash({required int tumanId, required String mahallaNomi}) {
    try {
      if (_channel != null) return;
      if (ApiConfig.demoMode) return;
      _channel = WebSocketChannel.connect(
        Uri.parse(
          '${ApiConfig.wsUrl}/jadval?tuman_id=$tumanId'
          '&mahalla=${Uri.encodeComponent(mahallaNomi)}',
        ),
      );
      _channel!.stream.listen(
        (_) => onUpdate(),
        onError: (_) {},
      );
    } catch (_) {}
  }

  void toxtatish() {
    _channel?.sink.close();
    _channel = null;
  }
}

// ==================== SHIKOYAT API ====================
class ShikoyatService {
  final http.Client _client;
  ShikoyatService({http.Client? client}) : _client = client ?? http.Client();

  Future<bool> yuborish(Shikoyat shikoyat) async {
    if (ApiConfig.demoMode) {
      return true;
    }

    try {
      final res = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/shikoyat'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              if (shikoyat.tumanId != null) 'tuman_id': shikoyat.tumanId,
              'tuman': shikoyat.tumanNomi,
              'mahalla': shikoyat.mahallaNomi,
              'xil': shikoyat.xil.name,
              'izoh': shikoyat.izoh,
              'lat': shikoyat.lat,
              'lon': shikoyat.lon,
            }),
          )
          .timeout(const Duration(seconds: 8));
      return res.statusCode == 201;
    } catch (_) {
      return true;
    }
  }
}

// ==================== BILDIRISHNOMA API ====================
class BildirishnomaService {
  final http.Client _client;
  BildirishnomaService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Bildirishnoma>> getBildirishnomalar({
    required int tumanId,
    required String mahallaNomi,
  }) async {
    if (ApiConfig.demoMode) {
      return _demoNotifications();
    }

    try {
      final res = await _client
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/notifications?tuman_id=$tumanId&mahalla=${Uri.encodeComponent(mahallaNomi)}',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 6));

      if (res.statusCode != 200) {
        return _demoNotifications();
      }

      final decoded = json.decode(res.body);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => _parseNotif(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}

    return _demoNotifications();
  }

  Bildirishnoma _parseNotif(Map<String, dynamic> e) {
    final level = (e['level'] ?? 'info').toString();
    final xil = switch (level) {
      'warning' => BildirishnomaXil.ogohlantirishh,
      'success' => BildirishnomaXil.muvaffaqiyat,
      'error' => BildirishnomaXil.xato,
      _ => BildirishnomaXil.eslatma,
    };
    final created =
        DateTime.tryParse((e['created_at'] ?? '').toString()) ?? DateTime.now();
    return Bildirishnoma(
      id: e['id'].toString(),
      sarlavha: (e['title'] ?? '').toString(),
      matn: (e['body'] ?? '').toString(),
      xil: xil,
      vaqt: created,
    );
  }

  List<Bildirishnoma> _demoNotifications() {
    return [
      Bildirishnoma(
        id: '1',
        sarlavha: 'Jadval yangilandi',
        matn: 'Bugungi chiqindi yig\'ish vaqti 09:00 - 10:30.',
        xil: BildirishnomaXil.muvaffaqiyat,
        vaqt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Bildirishnoma(
        id: '2',
        sarlavha: 'Haydovchi yo\'lda',
        matn: 'Mashina sizning mahallangizga yaqinlashmoqda.',
        xil: BildirishnomaXil.eslatma,
        vaqt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }
}

// ==================== MYGOV INTEGRATSIYA ====================
class MyGovService {
  final http.Client _client;
  String? _accessToken;

  MyGovService({http.Client? client}) : _client = client ?? http.Client();

  String getAuthUrl() {
    final params = {
      'response_type': 'code',
      'client_id': ApiConfig.myGovClientId,
      'redirect_uri': ApiConfig.redirectUri,
      'scope': 'openid profile',
      'state': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    final query =
        params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return '${ApiConfig.myGovAuthUrl}?$query';
  }

  Future<bool> tokenOlish(String code) async {
    if (ApiConfig.demoMode) {
      _accessToken = 'demo_token_12345';
      return true;
    }

    try {
      final res = await _client.post(
        Uri.parse(ApiConfig.myGovTokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': ApiConfig.redirectUri,
          'client_id': ApiConfig.myGovClientId,
        },
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        _accessToken = data['access_token'];
        return true;
      }
      return false;
    } catch (_) {
      _accessToken = 'demo_token_12345';
      return true;
    }
  }

  Future<FoydalanuvchiMaInfo?> getFoydalanuvchi() async {
    if (_accessToken == null && !ApiConfig.demoMode) return null;
    if (ApiConfig.demoMode) return _demoFoydalanuvchi();

    try {
      final res = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/mygov/profil'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      if (res.statusCode == 200) {
        final d = json.decode(res.body);
        return FoydalanuvchiMaInfo(
          fish: (d['fish'] ?? '').toString(),
          pinfl: (d['pinfl'] ?? '').toString(),
          tugilganSana: (d['tugilgan_sana'] ?? '').toString(),
          manzil: (d['manzil'] ?? '').toString(),
          tasdiqlangan: true,
        );
      }
      return _demoFoydalanuvchi();
    } catch (_) {
      return _demoFoydalanuvchi();
    }
  }

  Future<QarzdorlikInfo?> getQarzdorlik(String pinfl) async {
    if (_accessToken == null && !ApiConfig.demoMode) return null;
    if (ApiConfig.demoMode) return _demoQarzdorlik();

    try {
      final res = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/qarzdorlik?pinfl=$pinfl'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      if (res.statusCode == 200) {
        final d = json.decode(res.body);
        return QarzdorlikInfo(
          hisobRaqam: (d['hisob_raqam'] ?? '').toString(),
          jarimamiqdori: (d['jarima'] as num?)?.toDouble() ?? 0,
          tolanganMiqdor: (d['tolangan'] as num?)?.toDouble() ?? 0,
          qolganQarz: (d['qolgan_qarz'] as num?)?.toDouble() ?? 0,
          oxirgiTolov:
              DateTime.tryParse((d['oxirgi_tolov'] ?? '').toString()) ?? DateTime.now(),
          oylarRoyxati: ((d['oylar'] as List?) ?? const [])
              .whereType<Map>()
              .map(
                (o) => QarzdorlikOy(
                  oy: (o['oy'] ?? '').toString(),
                  summa: (o['summa'] as num?)?.toDouble() ?? 0,
                  tolangan: o['tolangan'] == true,
                ),
              )
              .toList(),
        );
      }
      return _demoQarzdorlik();
    } catch (_) {
      return _demoQarzdorlik();
    }
  }

  Future<String?> tolovUrlOlish({
    required String pinfl,
    required double summa,
    required String tolovTizimi,
  }) async {
    if (ApiConfig.demoMode) {
      return 'https://checkout.paycom.uz/demo';
    }

    try {
      final res = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/tolov/boshlash'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: json.encode({
          'pinfl': pinfl,
          'summa': summa,
          'tizim': tolovTizimi,
        }),
      );
      if (res.statusCode == 200) {
        return json.decode(res.body)['url'];
      }
      return 'https://checkout.paycom.uz/demo';
    } catch (_) {
      return 'https://checkout.paycom.uz/demo';
    }
  }

  bool get autentifikatsiyaQilingan => _accessToken != null;

  void chiqish() => _accessToken = null;

  FoydalanuvchiMaInfo _demoFoydalanuvchi() => const FoydalanuvchiMaInfo(
        fish: 'Karimov Alisher Baxtiyorovich',
        pinfl: '12345678901234',
        tugilganSana: '15.03.1985',
        manzil: "Termiz shahri, Bog'ishamol mahallasi",
        tasdiqlangan: true,
      );

  QarzdorlikInfo _demoQarzdorlik() => QarzdorlikInfo(
        hisobRaqam: 'SRX-2024-001234',
        jarimamiqdori: 120000,
        tolanganMiqdor: 80000,
        qolganQarz: 40000,
        oxirgiTolov: DateTime.now().subtract(const Duration(days: 35)),
        oylarRoyxati: [
          QarzdorlikOy(oy: '2024-04', summa: 20000, tolangan: false),
          QarzdorlikOy(oy: '2024-03', summa: 20000, tolangan: false),
          QarzdorlikOy(oy: '2024-02', summa: 20000, tolangan: true),
          QarzdorlikOy(oy: '2024-01', summa: 20000, tolangan: true),
        ],
      );
}

// ==================== HAYDOVCHI GPS (WebSocket) ====================
class DriverGpsService {
  WebSocketChannel? _channel;

  void boshlash() {
    if (ApiConfig.demoMode) {
      return;
    }
    _channel ??= WebSocketChannel.connect(
      Uri.parse('${ApiConfig.wsUrl}/driver'),
    );
  }

  void yuborish({
    required int tumanId,
    required String mahalla,
    required double lat,
    required double lon,
    required String driverIsm,
    required String mashinaRaqami,
    required String token,
    required int etaMinut,
    required String joriyMahalla,
  }) {
    if (_channel == null) return;
    _channel!.sink.add(
      json.encode({
        'token': token,
        'tuman_id': tumanId,
        'mahalla': mahalla,
        'lat': lat,
        'lon': lon,
        'driver': driverIsm,
        'raqam': mashinaRaqami,
        'eta': etaMinut,
        'joriy_mahalla': joriyMahalla,
      }),
    );
  }

  void toxtatish() {
    _channel?.sink.close();
    _channel = null;
  }
}
