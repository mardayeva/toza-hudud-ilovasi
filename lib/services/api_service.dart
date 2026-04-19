import 'dart:async';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/models.dart';

// ==================== API CONFIG ====================
class ApiConfig {
  static const bool demoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: true);

  static const String devServerIp = '192.168.100.150';

  static String get baseUrl =>
      kIsWeb ? 'http://127.0.0.1:8000/v1' : 'http://$devServerIp:8000/v1';

  static String get wsUrl =>
      kIsWeb ? 'ws://127.0.0.1:8000/ws' : 'ws://$devServerIp:8000/ws';
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
    if (ApiConfig.demoMode) return _demoJadval(mahallaNomi);

    final String url = driverId != null
        ? '${ApiConfig.baseUrl}/jadval?driver_id=$driverId'
        : '${ApiConfig.baseUrl}/jadval?tuman_id=$tumanId&mahalla=${Uri.encodeComponent(mahallaNomi)}';

    try {
      final res = await _client
          .get(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 3));

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
    } catch (_) {
      // fallback below
    }

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
    var eta = 25;
    _demoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      onUpdate(MashinaJoylashuv(
        lat: 37.224,
        lon: 67.278,
        driverIsm: 'Alisher Karimov',
        mashinaRaqami: '60 A 123 BA',
        etaMinut: eta,
        joriyMahalla: "Bog'ishamol",
      ));
      if (eta <= 0) {
        timer.cancel();
      } else {
        eta -= 5;
      }
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
  Timer? _demoTimer;
  final VoidCallback onUpdate;

  JadvalRealtimeService({required this.onUpdate});

  void boshlash({required int tumanId, required String mahallaNomi}) {
    try {
      if (_channel != null) return;
      if (ApiConfig.demoMode) {
        _demoTimer?.cancel();
        _demoTimer = Timer.periodic(const Duration(seconds: 12), (_) => onUpdate());
        return;
      }
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
    _demoTimer?.cancel();
    _demoTimer = null;
    _channel?.sink.close();
    _channel = null;
  }
}

// ==================== BILDIRISHNOMA REALTIME (WebSocket) ====================
class NotificationRealtimeService {
  WebSocketChannel? _channel;
  Timer? _demoTimer;
  final VoidCallback onUpdate;

  NotificationRealtimeService({required this.onUpdate});

  void boshlash({required int tumanId, required String mahallaNomi}) {
    try {
      if (_channel != null) return;
      if (ApiConfig.demoMode) {
        _demoTimer?.cancel();
        _demoTimer = Timer.periodic(const Duration(seconds: 15), (_) => onUpdate());
        return;
      }
      _channel = WebSocketChannel.connect(
        Uri.parse(
          '${ApiConfig.wsUrl}/notifications?tuman_id=$tumanId'
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
    _demoTimer?.cancel();
    _demoTimer = null;
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
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 201;
    } catch (_) {
      return false;
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
    if (ApiConfig.demoMode) return _demoNotifications();

    try {
      final res = await _client
          .get(
            Uri.parse(
              '${ApiConfig.baseUrl}/notifications?tuman_id=$tumanId&mahalla=${Uri.encodeComponent(mahallaNomi)}',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 3));

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
    } catch (_) {
      // fallback below
    }

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
