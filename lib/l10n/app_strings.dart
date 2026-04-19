import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;
  const AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context));
  }

  bool get _ru => locale.languageCode.toLowerCase().startsWith('ru');

  String get appTitle => 'Toza Hudud';
  String get appSubtitle => _ru ? 'Система чистой территории' : 'Toza hudud tizimi';

  String get start => _ru ? 'Начать' : 'Boshlash';
  String get districts => _ru ? 'Районы' : 'Tuman';
  String get neighborhoods => _ru ? 'Махалли' : 'Mahalla';
  String get chooseDistrict => _ru ? 'Выберите район' : 'Tuman tanlang';
  String get searchDistrict => _ru ? 'Поиск района...' : 'Tuman qidirish...';
  String get searchNeighborhood => _ru ? 'Поиск махалли...' : 'Mahalla qidirish...';
  String get allDistricts => _ru ? 'Все районы' : 'Barcha tumanlar';
  String get neighborhoodSuffix => _ru ? 'махалля' : 'mahallasi';
  String get oneTimeAreaHint => _ru
      ? 'Один раз выберите район и махаллю. Затем приложение всегда будет открывать этот участок.'
      : 'Hududingizni bir marta tanlang. Keyingi safar ilova shu mahallani avtomatik ochadi.';
  String get selectAreaTitle => _ru ? 'Выберите свой участок' : 'Hududingizni tanlang';
  String get selectAreaSubtitle => _ru
      ? 'Сначала выберите район и махаллю, затем нажмите «Войти».'
      : 'Bitta tuman va mahallani tanlaysiz, keyin shu hudud ochiladi.';
  String get continueLabel => _ru ? 'Войти' : 'Kirish';
  String get changeArea => _ru ? 'Сменить участок' : 'Hududni almashtirish';

  String get driverLogin => _ru ? 'Вход водителя' : 'Haydovchi kirish';
  String get language => _ru ? 'Сменить язык' : 'Tilni almashtirish';
  String get contact => _ru ? 'Контакты' : 'Aloqa';
  String get uzbek => _ru ? 'Узбекский' : "O'zbekcha";
  String get russian => _ru ? 'Русский' : 'Ruscha';

  String get schedule => _ru ? 'График' : 'Jadval';
  String get scheduleTitle => _ru ? 'График вывоза мусора' : 'Chiqindi yig\'ish jadvali';
  String get tracking => _ru ? 'Отслеживание' : 'Kuzatish';
  String get messages => _ru ? 'Сообщения' : 'Xabarlar';
  String get noSchedule => _ru ? 'График не найден' : 'Jadval topilmadi';
  String get tryAgain => _ru ? 'Повторить' : "Qayta urinib ko'rish";
  String get noMessages => _ru ? 'Сообщений нет' : "Xabarlar yo'q";
  String get messagesLoading => _ru ? 'Загрузка сообщений...' : 'Xabarlar yuklanmoqda...';
  String get upcomingSchedule => _ru ? 'Предстоящий график' : 'Keluvchi jadval';
  String get today => _ru ? 'Сегодня' : 'Bugun';
  String get arrives => _ru ? 'Приедет' : 'Keladi';
  String get finished => _ru ? 'Завершено' : 'Tugadi';
  String get canceled => _ru ? 'Отменено' : 'Bekor';
  String get locationLoading => _ru ? 'Определяется местоположение машины...' : 'Mashina joylashuvi aniqlanmoqda...';
  String get noDriverYet => _ru ? 'Пока нет данных о водителе' : "Hozircha haydovchi ma'lumoti yo'q";
  String get noDriverHint => _ru ? 'Водитель должен включить GPS' : 'Haydovchi GPSni yoqishi kerak';
  String get arrived => _ru ? 'Машина приехала!' : 'Mashina keldi!';
  String arrivesInMinutes(int m) => _ru ? 'Приедет через ~$m мин' : '~$m daqiqada keladi';
  String get toNeighborhood => _ru ? 'в махаллю' : 'mahallasiga';
  String get vehicleInfo => _ru ? 'Информация о машине' : 'Mashina ma\'lumoti';
  String get driver => _ru ? 'Водитель' : 'Haydovchi';
  String get vehicleNumber => _ru ? 'Номер машины' : 'Mashina raqami';
  String get now => _ru ? 'Сейчас' : 'Hozir';
  String get routeStops => _ru ? 'Остановки маршрута' : 'Marshrut to\'xtashlari';
  String get routeDone => _ru ? 'Завершено' : 'Tugadi';
  String get routeNext => _ru ? 'Следующая' : 'Keyingi';
  String get routeWaiting => _ru ? 'Ожидается' : 'Kutilmoqda';
  String get todayStatus => _ru ? 'Текущий статус' : 'Bugungi holat';
  String get truckOnRoad => _ru ? 'Машина в пути' : 'Mashina yo\'lda';
  String get arrivingAt => _ru ? 'Прибудет' : 'Yetib keladi';
  String get arrivesAtTime => _ru ? 'Прибудет в' : 'soat';
  String get routeCurrentStop => _ru ? 'Ваш участок' : 'Sizning hududingiz';
  String get routeDemoStart => _ru ? 'Улица Навои' : "Navoiy ko'chasi";
  String get routeDemoNext => _ru ? 'Махалля Дустлик' : "Do'stlik mahallasi";
  String get routeDemoYou => _ru ? 'Ваш участок' : 'Siz (hozir)';
  String get scheduleShort => _ru ? 'График' : 'Jadval';

  String get complaint => _ru ? 'Отправить жалобу' : 'Shikoyat yuborish';
  String get complaintTitle => _ru ? 'Жалоба' : 'Shikoyat';
  String get complaintIntro => _ru
      ? 'Сообщите о проблеме, и мы постараемся быстро её решить.'
      : 'Muammo haqida xabar bering va biz uni tezkorlik bilan bartaraf etamiz.';
  String get mashinaKelmadi => _ru ? 'Машина не приехала' : 'Mashina kelmadi';
  String get chiqindiQoldirildi => _ru ? 'Мусор оставлен' : 'Chiqindi qoldirildi';
  String get jadvalNotoGri => _ru ? 'Неверный график' : "Jadval noto'g'ri";
  String get maxsusChiqindi => _ru ? 'Спецотходы' : 'Maxsus chiqindi';
  String get boshqa => _ru ? 'Другое' : 'Boshqa';
  String get complaintDescription => _ru ? 'Описание проблемы' : 'Muammo tavsifi';
  String get issueType => _ru ? 'Тип проблемы' : 'Muammo turi';
  String get comment => _ru ? 'Комментарий' : 'Izoh';
  String get commentHint => _ru ? 'Введите дополнительную информацию...' : "Qo'shimcha ma'lumot kiriting...";
  String get addPhoto => _ru ? 'Добавить фото (необязательно)' : 'Foto qo\'shish (ixtiyoriy)';
  String get maxPhotoNotice => _ru ? 'МАКСИМУМ 5 ФОТО' : 'MAKSIMAL 5 TA RASM';
  String get locationAuto => _ru ? 'Ваше местоположение определяется автоматически' : 'Joylashuvingiz avtomatik aniqlanadi';
  String get location => _ru ? 'Местоположение' : 'Joylashuv';
  String get autoDetect => _ru ? 'Определить автоматически' : 'Avtomatik aniqlash';
  String get privacyNotice => _ru
      ? 'Ваши данные отправляются только по назначению. Ответим в течение 24 часов.'
      : 'Sizning ma\'lumotlaringiz faqat tegishli joyga yuboriladi. 24 soat ichida javob beramiz.';
  String get send => _ru ? 'Отправить' : 'Yuborish';
  String get complaintSent => _ru ? 'Жалоба отправлена!' : 'Shikoyat yuborildi!';
  String get willBeReviewed => _ru ? 'Скоро будет рассмотрено' : 'Tez orada ko\'rib chiqiladi';
  String get close => _ru ? 'Закрыть' : 'Yopish';
  String get sendError => _ru ? 'Ошибка отправки. Попробуйте снова.' : 'Yuborishda xatolik. Qaytadan urinib ko\'ring.';

  String get driverMode => _ru ? 'Режим водителя' : 'Haydovchi rejimi';
  String get login => _ru ? 'Логин' : 'Login';
  String get password => _ru ? 'Пароль' : 'Parol';
  String get wait => _ru ? 'Подождите...' : 'Kuting...';
  String get signIn => _ru ? 'Войти' : 'Kirish';
  String get loginError => _ru ? 'Неверный логин или пароль' : 'Login yoki parol noto\'g\'ri';
  String get gpsStopped => _ru ? 'Остановлено' : 'To\'xtatilgan';
  String get gpsDisabled => _ru ? 'GPS выключен' : 'GPS o\'chiq';
  String get gpsDenied => _ru ? 'Нет разрешения на GPS' : 'GPS ruxsati berilmadi';
  String get gpsSending => _ru ? 'Отправляется' : 'Yuborilmoqda';
  String get gpsStoppedShort => _ru ? 'Остановлено' : 'To\'xtatildi';
  String get locationNotYet => _ru ? 'Местоположение ещё не получено.' : 'Joylashuv hali olinmagan.';
  String get status => _ru ? 'Статус' : 'Holat';
  String get districtId => _ru ? 'ID района' : 'Tuman ID';
  String get neighborhood => _ru ? 'Махалля' : 'Mahalla';

  String get contactTitle => _ru ? 'Контакты' : 'Aloqa';
  String get contactInfo => _ru ? 'Контактная информация' : 'Aloqa ma\'lumotlari';
  String get contactDesc => _ru
      ? 'Если у вас есть вопрос, предложение или техническая проблема, свяжитесь с нами по каналам ниже.'
      : 'Savol, taklif yoki texnik muammo bo\'lsa, quyidagi kanallardan bog\'laning.';
  String get phone => _ru ? 'Телефон' : 'Telefon';

  String minutesShort(int m) => _ru ? '$m мин' : '$m daq';
  String hoursShort(int h) => _ru ? '$h ч' : '$h soat';
  String daysShort(int d) => _ru ? '$d дн' : '$d kun';
}
