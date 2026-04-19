// ==================== MODELS ====================

class Tuman {
  final int id;
  final String nomi;
  final String markaz;
  final List<String> mahallalar;

  const Tuman({
    required this.id,
    required this.nomi,
    required this.markaz,
    required this.mahallalar,
  });
}

class Mahalla {
  final int id;
  final String nomi;
  final int tumanId;
  final String tumanNomi;

  const Mahalla({
    required this.id,
    required this.nomi,
    required this.tumanId,
    required this.tumanNomi,
  });
}

class JadvalItem {
  final String id;
  final String mahallaNomi;
  final String tumanNomi;
  final DateTime sana;
  final String boshlanish; // "09:00"
  final String tugash;     // "10:30"
  final JadvalHolat holat;
  final int? driverId;

  const JadvalItem({
    required this.id,
    required this.mahallaNomi,
    required this.tumanNomi,
    required this.sana,
    required this.boshlanish,
    required this.tugash,
    required this.holat,
    this.driverId,
  });

  bool get bugun {
    final now = DateTime.now();
    return sana.year == now.year &&
        sana.month == now.month &&
        sana.day == now.day;
  }
}

enum JadvalHolat { keladi, bugun, tugadi, bekor }

class MashinaJoylashuv {
  final double lat;
  final double lon;
  final String driverIsm;
  final String mashinaRaqami;
  final int etaMinut; // qancha daqiqada yetib keladi
  final String joriyMahalla;

  const MashinaJoylashuv({
    required this.lat,
    required this.lon,
    required this.driverIsm,
    required this.mashinaRaqami,
    required this.etaMinut,
    required this.joriyMahalla,
  });
}

class Bildirishnoma {
  final String id;
  final String sarlavha;
  final String matn;
  final BildirishnomaXil xil;
  final DateTime vaqt;
  final bool oqilgan;

  const Bildirishnoma({
    required this.id,
    required this.sarlavha,
    required this.matn,
    required this.xil,
    required this.vaqt,
    this.oqilgan = false,
  });
}

enum BildirishnomaXil { eslatma, ogohlantirishh, muvaffaqiyat, xato }

class Shikoyat {
  final String id;
  final int? tumanId;
  final String tumanNomi;
  final String mahallaNomi;
  final ShikoyatXil xil;
  final String izoh;
  final String? fotoUrl;
  final double? lat;
  final double? lon;
  final ShikoyatHolat holat;
  final DateTime yuborilganVaqt;

  const Shikoyat({
    required this.id,
    this.tumanId,
    required this.tumanNomi,
    required this.mahallaNomi,
    required this.xil,
    required this.izoh,
    this.fotoUrl,
    this.lat,
    this.lon,
    required this.holat,
    required this.yuborilganVaqt,
  });
}

enum ShikoyatXil {
  mashinaKelmadi,
  chiqindiQoldirildi,
  jadvalNotoGri,
  maxsusChiqindi,
  boshqa
}

enum ShikoyatHolat { yuborildi, korilibChiqilmoqda, halEtildi, bekor }
