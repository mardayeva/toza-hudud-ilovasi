# ChiqindiNav — Surxondaryo viloyati chiqindi yig'ish ilovasi

## Loyiha tuzilmasi

```
lib/
├── main.dart                    # Ilovaning kirish nuqtasi
├── theme.dart                   # Rang va dizayn sozlamalari
├── models/
│   └── models.dart              # Barcha data modellari
├── data/
│   └── surxondaryo_db.dart      # 14 tuman, 543 mahalla bazasi

└── screens/
    ├── main_screens.dart         # Splash, Tuman, Mahalla ekranlari
    ├── jadval_screen.dart        # Jadval + Kuzatish + Bildirishnomalar
    ├── shikoyat_screen.dart      # Shikoyat yuborish
    
```

## O'rnatish

```bash
# Flutter o'rnatilgan bo'lishi kerak (3.0+)
flutter pub get
flutter run
```

## Haydovchi rejimi (background GPS)

- Android: `ACCESS_BACKGROUND_LOCATION` va `FOREGROUND_SERVICE` ruxsatlari qo'shildi.
- iOS: `UIBackgroundModes` ichida `location` yoqilgan.

Eslatma:
- iOS uchun Xcode'da `Signing & Capabilities` -> `Background Modes` -> `Location updates` yoqilishi kerak.
- Androidda fon rejimida ishlash uchun foreground notification ko'rinadi (bu talab).

## Asosiy funksiyalar

### 1. Jadval ko'rish
- 14 tuman, 543 mahalla bo'yicha jadval
- Haftalik ko'rinish
- Bugungi jadval ajratib ko'rsatiladi

### 2. Mashina kuzatish (real vaqt)
- WebSocket orqali GPS kuzatish
- ETA (qancha daqiqada kelishi)
- Marshrut to'xtashlari

### 3. Bildirishnomalar
- 30 daqiqa oldin eslatma
- Jadval o'zgarishi haqida xabar
- Shikoyat javobi

### 4. Shikoyat yuborish
- Muammo turini tanlash
- Foto biriktirish
- Joylashuv avtomatik aniqlanadi

## Backend API

Backend quyidagi endpointlarni taqdim etishi kerak:

| Endpoint | Metod | Tavsif |
|---|---|---|
| /v1/jadval | GET | Jadval ma'lumotlari |
| /v1/shikoyat | POST | Shikoyat yuborish |
| ws://api.../ws/mashina | WS | Real vaqt GPS |


## Texnologiyalar

- **Flutter 3.x** — cross-platform
- **WebSocket** — real vaqt mashina kuzatish
- **Geolocator** — joylashuv aniqlash
