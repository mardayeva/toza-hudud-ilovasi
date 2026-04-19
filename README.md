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
├── services/
│   └── api_service.dart         # API + MyGov + WebSocket xizmatlari
└── screens/
    ├── main_screens.dart         # Splash, Tuman, Mahalla ekranlari
    ├── jadval_screen.dart        # Jadval + Kuzatish + Bildirishnomalar
    ├── shikoyat_screen.dart      # Shikoyat yuborish
    └── profil_screen.dart        # MyGov profil + Qarzdorlik
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

### 5. MyGov integratsiya
- OAuth2 orqali shaxsni tasdiqlash
- PINFL bo'yicha qarzdorlik tekshirish
- Real vaqt rejimi
- Payme / Click orqali to'lov

## Backend API

Backend quyidagi endpointlarni taqdim etishi kerak:

| Endpoint | Metod | Tavsif |
|---|---|---|
| /v1/jadval | GET | Jadval ma'lumotlari |
| /v1/shikoyat | POST | Shikoyat yuborish |
| /v1/mygov/profil | GET | Foydalanuvchi ma'lumoti |
| /v1/qarzdorlik | GET | Qarzdorlik holati |
| /v1/tolov/boshlash | POST | To'lov URL generatsiya |
| ws://api.../ws/mashina | WS | Real vaqt GPS |

## MyGov integratsiya haqida

MyGov OAuth2 ni ishlatish uchun:

1. `id.egov.uz` da ro'yxatdan o'ting
2. `client_id` va `client_secret` oling
3. `api_service.dart` dagi `ApiConfig.myGovClientId` ni o'zgartiring
4. Android uchun deep link sozlang (`android/app/src/main/AndroidManifest.xml`)

## Texnologiyalar

- **Flutter 3.x** — cross-platform
- **WebSocket** — real vaqt mashina kuzatish
- **MyGov OAuth2** — shaxs tasdiqlanishi
- **Payme / Click** — to'lov tizimlari
- **Geolocator** — joylashuv aniqlash
