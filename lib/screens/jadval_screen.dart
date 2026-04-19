import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../l10n/app_strings.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'app_drawer.dart';
import 'shikoyat_screen.dart';

class JadvalScreen extends StatefulWidget {
  final int tumanId;
  final String tumanNomi;
  final String mahallaNomi;

  const JadvalScreen({
    super.key,
    required this.tumanId,
    required this.tumanNomi,
    required this.mahallaNomi,
  });

  @override
  State<JadvalScreen> createState() => _JadvalScreenState();
}

class _JadvalScreenState extends State<JadvalScreen> {
  int _tab = 0;
  List<JadvalItem> _jadval = [];
  MashinaJoylashuv? _mashina;
  bool _loading = true;
  String _error = '';
  bool _timeout = false;
  Timer? _timeoutTimer;
  final _jadvalService = JadvalService();
  late final MashinaKuzatishService _mashinaService;
  late final JadvalRealtimeService _realtimeService;

  @override
  void initState() {
    super.initState();
    _mashinaService = MashinaKuzatishService(
      onUpdate: (m) {
        _timeoutTimer?.cancel();
        if (!mounted) return;
        setState(() {
          _mashina = m;
          _timeout = false;
        });
      },
    );
    _realtimeService = JadvalRealtimeService(onUpdate: _reload);
    _reload();
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = '';
      _jadval = [];
      _mashina = null;
      _timeout = false;
    });

    List<JadvalItem> next = [];
    try {
      next = await _jadvalService.getJadval(
        tumanId: widget.tumanId,
        mahallaNomi: widget.mahallaNomi,
      );
    } catch (_) {
      _error = AppStrings.of(context).sendError;
    }

    _mashinaService.boshlash(
      tumanId: widget.tumanId,
      mahallaNomi: widget.mahallaNomi,
    );
    _realtimeService.boshlash(
      tumanId: widget.tumanId,
      mahallaNomi: widget.mahallaNomi,
    );

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted || _mashina != null) return;
      setState(() => _timeout = true);
    });

    if (!mounted) return;
    setState(() {
      _jadval = next;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _mashinaService.toxtatish();
    _realtimeService.toxtatish();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final tabs = [
      _JadvalTab(
        jadval: _jadval,
        loading: _loading,
        error: _error,
        onRefresh: _reload,
      ),
      _KuzatishTab(
        mashina: _mashina,
        mahallaNomi: widget.mahallaNomi,
        timeout: _timeout,
        onRefresh: _reload,
      ),
      _BildirishnomaTab(
        tumanId: widget.tumanId,
        mahallaNomi: widget.mahallaNomi,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryDark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chiqindi yig\'ish jadvali',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              '${widget.mahallaNomi} ${s.neighborhoodSuffix}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
          IconButton(
            icon: const Icon(Icons.report_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShikoyatScreen(
                  tumanId: widget.tumanId,
                  tumanNomi: widget.tumanNomi,
                  mahallaNomi: widget.mahallaNomi,
                ),
              ),
            ),
          ),
        ],
      ),
      body: tabs[_tab],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primaryLight,
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: s.schedule,
          ),
          NavigationDestination(
            icon: const Icon(Icons.gps_fixed_outlined),
            selectedIcon: const Icon(Icons.gps_fixed),
            label: s.tracking,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_none),
            selectedIcon: const Icon(Icons.notifications),
            label: s.messages,
          ),
        ],
      ),
    );
  }
}

class _JadvalTab extends StatelessWidget {
  final List<JadvalItem> jadval;
  final bool loading;
  final String error;
  final VoidCallback onRefresh;

  const _JadvalTab({
    required this.jadval,
    required this.loading,
    required this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    if (loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (jadval.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_busy, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  s.noSchedule,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                if (error.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(error, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: 180,
                  child: OutlinedButton(
                    onPressed: onRefresh,
                    child: Text(s.tryAgain),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final today = jadval.where((j) => j.bugun).toList();
    final upcoming = jadval.where((j) => !j.bugun).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (today.isNotEmpty) ...[
          _HeroKarta(jadval: today.first),
          const SizedBox(height: 16),
        ],
        if (upcoming.isNotEmpty) ...[
          _SectionLabel(text: s.upcomingSchedule),
          const SizedBox(height: 12),
          ...upcoming.map((j) => _JadvalTile(jadval: j)),
        ],
      ],
    );
  }
}

class _HeroKarta extends StatelessWidget {
  final JadvalItem jadval;

  const _HeroKarta({required this.jadval});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D631B), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.recycling_outlined,
              size: 120,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BUGUNGI HOLAT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mashina yo\'lda',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '№ 752 ABC - ${jadval.boshlanish} da yetib keladi',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JadvalTile extends StatelessWidget {
  final JadvalItem jadval;

  const _JadvalTile({required this.jadval});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final dayFmt = DateFormat('dd');
    final dayName = DateFormat('EEEE', s.locale.languageCode == 'ru' ? 'ru' : 'uz');
    final holatRang = jadval.holat == JadvalHolat.bugun
        ? AppTheme.primary
        : jadval.holat == JadvalHolat.keladi
            ? AppTheme.info
            : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: holatRang.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  dayFmt.format(jadval.sana),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: holatRang,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayName.format(jadval.sana),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${jadval.boshlanish} - ${jadval.tugash}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            _StatusBadge(holat: jadval.holat),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final JadvalHolat holat;

  const _StatusBadge({required this.holat});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final (text, bg, fg) = switch (holat) {
      JadvalHolat.bugun => (s.today, AppTheme.primaryLight, AppTheme.primaryDark),
      JadvalHolat.keladi => (s.arrives, AppTheme.infoLight, const Color(0xFF0C447C)),
      JadvalHolat.tugadi => (s.finished, const Color(0xFFF1EFE8), Colors.grey),
      JadvalHolat.bekor => (s.canceled, AppTheme.dangerLight, AppTheme.danger),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _KuzatishTab extends StatelessWidget {
  final MashinaJoylashuv? mashina;
  final String mahallaNomi;
  final bool timeout;
  final VoidCallback onRefresh;

  const _KuzatishTab({
    this.mashina,
    required this.mahallaNomi,
    required this.timeout,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    if (mashina == null && !timeout) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.primary),
            const SizedBox(height: 16),
            Text(s.locationLoading, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    if (mashina == null && timeout) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 46, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                s.noDriverYet,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                s.noDriverHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 180,
                child: OutlinedButton(
                  onPressed: onRefresh,
                  child: Text(s.tryAgain),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final current = mashina!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Container(
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(current.lat, current.lon),
                initialZoom: 14.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'uz.chiqindinav.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(current.lat, current.lon),
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.local_shipping, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: current.etaMinut <= 10 ? AppTheme.warningLight : AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                color: current.etaMinut <= 10 ? AppTheme.warning : AppTheme.primary,
                size: 34,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.etaMinut == 0
                          ? s.arrived
                          : s.arrivesInMinutes(current.etaMinut),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: current.etaMinut <= 10 ? AppTheme.warning : AppTheme.primary,
                      ),
                    ),
                    Text(
                      '$mahallaNomi ${s.toNeighborhood}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(text: s.vehicleInfo),
                const SizedBox(height: 8),
                _InfoRow(Icons.person_outline, s.driver, current.driverIsm),
                _InfoRow(Icons.directions_car_outlined, s.vehicleNumber, current.mashinaRaqami),
                _InfoRow(Icons.location_on_outlined, s.now, current.joriyMahalla),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(text: s.routeStops),
                const SizedBox(height: 8),
                _MarshurutTile(nom: "Navoiy ko'chasi", holat: 'done'),
                _MarshurutTile(nom: '$mahallaNomi (siz)', holat: 'next'),
                _MarshurutTile(nom: "Do'stlik mahallasi", holat: 'wait'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MarshurutTile extends StatelessWidget {
  final String nom;
  final String holat;

  const _MarshurutTile({required this.nom, required this.holat});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final (dot, badge, badgeText) = switch (holat) {
      'done' => (AppTheme.primary, AppTheme.primaryLight, s.routeDone),
      'next' => (AppTheme.warning, AppTheme.warningLight, s.routeNext),
      _ => (AppTheme.info, AppTheme.infoLight, s.routeWaiting),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              nom,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: badge, borderRadius: BorderRadius.circular(999)),
            child: Text(
              badgeText,
              style: TextStyle(fontSize: 10, color: dot, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BildirishnomaTab extends StatefulWidget {
  final int tumanId;
  final String mahallaNomi;

  const _BildirishnomaTab({
    required this.tumanId,
    required this.mahallaNomi,
  });

  @override
  State<_BildirishnomaTab> createState() => _BildirishnomaTabState();
}

class _BildirishnomaTabState extends State<_BildirishnomaTab> {
  final _service = BildirishnomaService();
  bool _loading = true;
  String _error = '';
  List<Bildirishnoma> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final data = await _service.getBildirishnomalar(
        tumanId: widget.tumanId,
        mahallaNomi: widget.mahallaNomi,
      );
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = AppStrings.of(context).sendError;
        _items = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.primary),
            const SizedBox(height: 12),
            Text(s.messagesLoading, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_off, size: 46, color: Colors.grey),
              const SizedBox(height: 10),
              Text(
                s.noMessages,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(_error, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: 180,
                child: OutlinedButton(
                  onPressed: _load,
                  child: Text(s.tryAgain),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: _items.length,
      itemBuilder: (_, i) => _BildirishnomaTile(b: _items[i]),
    );
  }
}

class _BildirishnomaTile extends StatelessWidget {
  final Bildirishnoma b;

  const _BildirishnomaTile({required this.b});

  @override
  Widget build(BuildContext context) {
    final (icon, bg, fg) = switch (b.xil) {
      BildirishnomaXil.ogohlantirishh => (Icons.warning_amber_outlined, AppTheme.warningLight, AppTheme.warning),
      BildirishnomaXil.muvaffaqiyat => (Icons.check_circle_outline, AppTheme.primaryLight, AppTheme.primary),
      BildirishnomaXil.xato => (Icons.error_outline, AppTheme.dangerLight, AppTheme.danger),
      BildirishnomaXil.eslatma => (Icons.info_outline, AppTheme.infoLight, AppTheme.info),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: fg, size: 18),
        ),
        title: Text(
          b.sarlavha,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(b.matn, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 0.8,
      ),
    );
  }
}
