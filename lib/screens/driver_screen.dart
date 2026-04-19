import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../data/surxondaryo_db.dart';
import '../models/models.dart';
import '../theme.dart';
import '../l10n/app_strings.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final _tumanIdCtrl = TextEditingController(text: '1');
  final _mahallaCtrl = TextEditingController(text: "Bog'ishamol");

  final _gpsService = DriverGpsService();
  final _jadvalService = JadvalService();
  StreamSubscription<Position>? _sub;
  String _status = '';
  Position? _lastPos;
  Map<String, String>? _driverProfile;
  List<JadvalItem> _jadval = [];
  bool _jadvalLoading = false;

  @override
  void initState() {
    super.initState();
    AuthService().getDriverProfile().then((p) {
      if (p == null || !mounted) return;
      setState(() => _driverProfile = p);
      final tumanId = int.tryParse(p['tuman_id'] ?? '');
      final mahalla = p['mahalla'];
      if (tumanId != null) {
        _tumanIdCtrl.text = tumanId.toString();
      }
      if (mahalla != null && mahalla.isNotEmpty) {
        _mahallaCtrl.text = mahalla;
      }
      _loadJadval();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _status = AppStrings.of(context).gpsStopped);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _gpsService.toxtatish();
    super.dispose();
  }

  Future<void> _loadJadval() async {
    final tumanId = int.tryParse(_tumanIdCtrl.text) ?? 1;
    final mahalla = _mahallaCtrl.text.trim();
    final driverId = int.tryParse(_driverProfile?['driver_id'] ?? '');
    if (driverId == null && mahalla.isEmpty) return;
    setState(() => _jadvalLoading = true);
    try {
      final jadval = await _jadvalService.getJadval(
        tumanId: tumanId,
        mahallaNomi: mahalla,
        driverId: driverId,
      );
      if (!mounted) return;
      setState(() {
        _jadval = jadval;
        _jadvalLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _jadval = [];
        _jadvalLoading = false;
      });
    }
  }

  Future<void> _start() async {
    final s = AppStrings.of(context);
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _status = s.gpsDisabled);
      await Geolocator.openLocationSettings();
      return;
    }
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      final req = await Geolocator.requestPermission();
      if (req == LocationPermission.denied || req == LocationPermission.deniedForever) {
        setState(() => _status = s.gpsDenied);
        return;
      }
    }

    final tumanId = int.tryParse(_tumanIdCtrl.text) ?? 1;
    final mahalla = _mahallaCtrl.text.trim();
    await _loadJadval();
    _gpsService.boshlash();

    final locationSettings = switch (defaultTargetPlatform) {
      TargetPlatform.android => AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 15,
          foregroundNotificationConfig: ForegroundNotificationConfig(
            notificationTitle: s.appTitle,
            notificationText: s.gpsSending,
            enableWakeLock: true,
          ),
        ),
      TargetPlatform.iOS => AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 15,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
        ),
      _ => const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 15,
        ),
    };

    _sub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((pos) {
      _lastPos = pos;
      AuthService().getDriverToken().then((token) {
        if (token == null) return;
        _gpsService.yuborish(
          tumanId: tumanId,
          mahalla: mahalla,
          lat: pos.latitude,
          lon: pos.longitude,
          driverIsm: _driverProfile?['full_name'] ?? AppStrings.of(context).driver,
          mashinaRaqami: _driverProfile?['vehicle_number'] ?? '- ',
          token: token,
          etaMinut: 10,
          joriyMahalla: mahalla,
        );
      });
      setState(() => _status = s.gpsSending);
    });
  }

  void _stop() {
    _sub?.cancel();
    _gpsService.toxtatish();
    setState(() => _status = AppStrings.of(context).gpsStoppedShort);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final tumanId = int.tryParse(_tumanIdCtrl.text);
    final tumanNomi = tumanId == null
        ? null
        : SurxondaryoDB.getTuman(tumanId).nomi;
    final fmt = DateFormat('dd.MM.yyyy');
    return Scaffold(
      appBar: AppBar(title: Text(s.driverMode)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.primaryLight,
                      child: const Icon(Icons.local_shipping, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_driverProfile?['full_name'] ?? s.driver,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('${s.vehicleNumber}: ${_driverProfile?['vehicle_number'] ?? '-'}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Text(_driverProfile?['login'] ?? '',
                        style: const TextStyle(fontSize: 11, color: AppTheme.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(s.schedule.toUpperCase(),
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600,
                                color: Colors.grey[500], letterSpacing: 0.5)),
                        const Spacer(),
                        TextButton(
                          onPressed: _loadJadval,
                          child: Text(s.tryAgain),
                        ),
                      ],
                    ),
                    Text(
                      tumanNomi ?? s.districtId,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _mahallaCtrl.text.trim().isEmpty
                          ? s.neighborhood
                          : _mahallaCtrl.text.trim(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 10),
                    if (_jadvalLoading)
                      const LinearProgressIndicator(color: AppTheme.primary)
                    else if (_jadval.isEmpty)
                      Text(
                        s.noSchedule,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      )
                    else
                      Text(
                        '${fmt.format(_jadval.first.sana)}  ${_jadval.first.boshlanish}-${_jadval.first.tugash}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_jadval.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.routeStops.toUpperCase(),
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600,
                              color: Colors.grey[500], letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      ..._jadval.take(5).map((j) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.place_outlined, size: 14, color: AppTheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${j.mahallaNomi} · ${j.boshlanish}-${j.tugash}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Text(fmt.format(j.sana),
                                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            if (_jadval.isNotEmpty) const SizedBox(height: 10),
            if (_lastPos != null)
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(_lastPos!.latitude, _lastPos!.longitude),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: "uz.tozahudud.app",
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_lastPos!.latitude, _lastPos!.longitude),
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                              child: const Icon(Icons.navigation, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (_lastPos == null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(s.locationNotYet),
              ),
            const SizedBox(height: 12),
            Text('${s.status}: $_status', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            _field(s.districtId, _tumanIdCtrl),
            const SizedBox(height: 10),
            _field(s.neighborhood, _mahallaCtrl),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _start,
                    child: Text(s.start),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _stop,
                    child: Text(s.gpsStoppedShort),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) => TextField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label),
      );
}

