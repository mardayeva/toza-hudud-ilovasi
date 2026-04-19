import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;
  const AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context));
  }

  bool get _ru => locale.languageCode.toLowerCase().startsWith('ru');

  String get appTitle => 'Toza Hudud';
  String get appSubtitle => _ru
      ? 'Система чистой территории'
      : 'Toza hudud tizimi';

  String get start => _ru ? 'Начать' : 'Boshlash';
  String get districts => _ru ? 'Районы' : 'Tuman';
  String get neighborhoods => _ru ? 'Махалли' : 'Mahalla';
  String get chooseDistrict => _ru ? 'Выберите район' : 'Tuman tanlang';
  String get searchDistrict => _ru ? 'Поиск района...' : 'Tuman qidirish...';
  String get searchNeighborhood =>
      _ru ? 'Поиск махалли...' : 'Mahalla qidirish...';
  String get allDistricts => _ru ? 'Все районы' : 'Barcha tumanlar';
  String get neighborhoodSuffix => _ru ? 'махалля' : 'mahallasi';

  String get driverLogin => _ru ? 'Вход водителя' : 'Haydovchi kirish';
  String get language => _ru ? 'Сменить язык' : 'Tilni almashtirish';
  String get contact => _ru ? 'Контакты' : 'Aloqa';
  String get uzbek => _ru ? 'Узбекский' : 'O\'zbekcha';
  String get russian => _ru ? 'Русский' : 'Ruscha';

  String get schedule => _ru ? 'График' : 'Jadval';
  String get tracking => _ru ? 'Отслеживание' : 'Kuzatish';
  String get messages => _ru ? 'Сообщения' : 'Xabarlar';
  String get noSchedule => _ru ? 'График не найден' : 'Jadval topilmadi';
  String get tryAgain => _ru ? 'Повторить' : "Qayta urinib ko'rish";
  String get noMessages => _ru ? 'Сообщений нет' : "Xabarlar yo'q";
  String get messagesLoading => _ru ? 'Загрузка сообщений...' : "Xabarlar yuklanmoqda...";

  String get upcomingSchedule => _ru ? 'Предстоящий график' : 'Keluvchi jadval';
  String get nextPickup => _ru ? 'Следующий вывоз' : 'Keyingi yig\'ish';
  String get today => _ru ? 'Сегодня' : 'Bugun';
  String get arrives => _ru ? 'Приедет' : 'Keladi';
  String get finished => _ru ? 'Завершено' : 'Tugadi';
  String get canceled => _ru ? 'Отменено' : 'Bekor';

  String get locationLoading =>
      _ru ? 'Определяется местоположение машины...' : 'Mashina joylashuvi aniqlanmoqda...';
  String get noDriverYet =>
      _ru ? 'Пока нет данных водителя' : "Hozircha haydovchi ma'lumoti yo'q";
  String get noDriverHint =>
      _ru ? 'Водитель должен включить GPS' : 'Haydovchi GPSni yoqishi kerak';
  String get arrived => _ru ? 'Машина приехала!' : 'Mashina keldi!';
  String arrivesInMinutes(int m) =>
      _ru ? 'Приедет через ~$m мин.' : '~$m daqiqada keladi';
  String get toNeighborhood =>
      _ru ? 'в махаллю' : 'mahallasiga';

  String get vehicleInfo => _ru ? 'Информация о машине' : 'Mashina ma\'lumoti';
  String get driver => _ru ? 'Водитель' : 'Haydovchi';
  String get vehicleNumber => _ru ? 'Номер машины' : 'Mashina raqami';
  String get now => _ru ? 'Сейчас' : 'Hozir';

  String get routeStops => _ru ? 'Остановки маршрута' : 'Marshrut to\'xtashlari';
  String get routeDone => _ru ? 'Завершено' : 'Tugadi';
  String get routeNext => _ru ? 'Следующая' : 'Keyingi';
  String get routeWaiting => _ru ? 'Ожидается' : 'Kutilmoqda';

  String get complaint => _ru ? 'Отправить жалобу' : 'Shikoyat yuborish';
  String get issueType => _ru ? 'Тип проблемы' : 'Muammo turi';
  String get comment => _ru ? 'Комментарий' : 'Izoh';
  String get commentHint => _ru
      ? 'Введите дополнительную информацию...'
      : "Qo'shimcha ma'lumot kiriting...";
  String get addPhoto => _ru ? 'Добавить фото (необязательно)' : 'Foto qo\'shish (ixtiyoriy)';
  String get locationAuto =>
      _ru ? 'Ваше местоположение определяется автоматически' : 'Joylashuvingiz avtomatik aniqlanadi';
  String get send => _ru ? 'Отправить' : 'Yuborish';
  String get complaintSent => _ru ? 'Жалоба отправлена!' : 'Shikoyat yuborildi!';
  String get willBeReviewed =>
      _ru ? 'Скоро будет рассмотрено' : 'Tez orada ko\'rib chiqiladi';
  String get close => _ru ? 'Закрыть' : 'Yopish';
  String get sendError =>
      _ru ? 'Ошибка отправки. Попробуйте снова.' : 'Yuborishda xatolik. Qaytadan urinib ko\'ring.';

  String get driverMode => _ru ? 'Режим водителя' : 'Haydovchi rejimi';
  String get login => _ru ? 'Логин' : 'Login';
  String get password => _ru ? 'Пароль' : 'Parol';
  String get wait => _ru ? 'Подождите...' : 'Kuting...';
  String get signIn => _ru ? 'Войти' : 'Kirish';
  String get loginError => _ru ? 'Неверный логин или пароль' : 'Login yoki parol noto\'g\'ri';

  String get gpsStopped => _ru ? 'Остановлено' : 'Toxtatilgan';
  String get gpsDisabled => _ru ? 'GPS выключен' : 'GPS o‘chiq';
  String get gpsDenied => _ru ? 'Нет разрешения на GPS' : 'GPS ruxsati berilmadi';
  String get gpsSending => _ru ? 'Отправляется' : 'Yuborilmoqda';
  String get gpsStoppedShort => _ru ? 'Остановлено' : 'Toxtatildi';
  String get locationNotYet => _ru ? 'Местоположение еще не получено.' : 'Joylashuv hali olinmagan.';
  String get status => _ru ? 'Статус' : 'Holat';
  String get districtId => _ru ? 'ID района' : 'Tuman ID';
  String get neighborhood => _ru ? 'Mahalla' : 'Mahalla';

  String get contactTitle => _ru ? 'Контакты' : 'Aloqa';
  String get contactInfo => _ru ? 'Контактная информация' : 'Aloqa ma\'lumotlari';

  String minutesShort(int m) => _ru ? '$m мин' : '$m daq';
  String hoursShort(int h) => _ru ? '$h ч' : '$h soat';
  String daysShort(int d) => _ru ? '$d дн' : '$d kun';
}
