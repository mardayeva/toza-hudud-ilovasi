import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme.dart';

class ShikoyatScreen extends StatefulWidget {
  final int tumanId;
  final String tumanNomi;
  final String mahallaNomi;

  const ShikoyatScreen({
    super.key,
    required this.tumanId,
    required this.tumanNomi,
    required this.mahallaNomi,
  });

  @override
  State<ShikoyatScreen> createState() => _ShikoyatScreenState();
}

class _ShikoyatScreenState extends State<ShikoyatScreen> {
  ShikoyatXil _xil = ShikoyatXil.mashinaKelmadi;
  final _izohCtrl = TextEditingController();
  bool _yuborilmoqda = false;

  Map<ShikoyatXil, String> _xillar(AppStrings s) => {
        ShikoyatXil.mashinaKelmadi: s.mashinaKelmadi,
        ShikoyatXil.chiqindiQoldirildi: s.chiqindiQoldirildi,
        ShikoyatXil.jadvalNotoGri: s.jadvalNotoGri,
        ShikoyatXil.maxsusChiqindi: s.maxsusChiqindi,
        ShikoyatXil.boshqa: s.boshqa,
      };

  Future<void> _yuborish() async {
    setState(() => _yuborilmoqda = true);
    final service = ShikoyatService();
    final shikoyat = Shikoyat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tumanId: widget.tumanId,
      tumanNomi: widget.tumanNomi,
      mahallaNomi: widget.mahallaNomi,
      xil: _xil,
      izoh: _izohCtrl.text,
      holat: ShikoyatHolat.yuborildi,
      yuborilganVaqt: DateTime.now(),
    );
    final ok = await service.yuborish(shikoyat);
    if (!mounted) return;
    setState(() => _yuborilmoqda = false);
    if (ok) {
      _muvaffaqiyatDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).sendError)),
      );
    }
  }

  void _muvaffaqiyatDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppTheme.primary, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.of(context).complaintSent,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.of(context).willBeReviewed,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              AppStrings.of(context).close,
              style: const TextStyle(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final xillar = _xillar(s);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.appTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            s.complaint,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryDark,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            s.complaintIntro,
            style: TextStyle(
              fontSize: 17,
              height: 1.45,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.edit_note, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      s.complaintDescription,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _izohCtrl,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: s.commentHint,
                    fillColor: const Color(0xFFF3F3F3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: AppTheme.primary, size: 34),
                ),
                const SizedBox(height: 18),
                Text(
                  s.addPhoto,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  s.maxPhotoNotice,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFFD9DFD7), Color(0xFFBFC6BE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 18,
                  top: 18,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.location_on_outlined, color: AppTheme.primary),
                  ),
                ),
                Positioned(
                  left: 34,
                  bottom: 44,
                  child: Text(
                    s.location,
                    style: TextStyle(
                      color: Colors.grey.shade900,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Positioned(
                  left: 34,
                  bottom: 16,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(s.autoDetect),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_outlined, color: AppTheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s.privacyNotice,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            s.issueType,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...xillar.entries.map(
            (e) => RadioListTile<ShikoyatXil>(
              value: e.key,
              groupValue: _xil,
              onChanged: (v) => setState(() => _xil = v!),
              title: Text(e.value),
              activeColor: AppTheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _yuborilmoqda ? null : _yuborish,
              child: _yuborilmoqda
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(s.send),
            ),
          ),
        ],
      ),
    );
  }
}

