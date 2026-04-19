import '../models/models.dart';

class SurxondaryoDB {
  static const List<Tuman> tumanlar = [
    Tuman(id: 1, nomi: 'Boysun tumani', markaz: 'Boysun shahri', mahallalar: [
      'Tuzbozor','Chorchinor',"Bog'ibolo",'Ariqusti',"Tog'chi",'Obi',
      'Kosiblar','Mustaqillik','Poygaboshi','Gaza',"Sho'rsoy",'Inkobod',
      'Duoba',"Xo'jaidod","O'rmonchi",'Dehibolo','Boshrabot','Kofrun',
      "Ko'chkak",'Sariosiyo','Avlod','Pasurxi','Shirinobod','Bibishirin',
      "To'da","Xo'jabo'lg'on",'Tillokamar','Sayrob','Munchoq','Chilonzor',
      'Dahnaijom','Darband','Temirdarvoza','Shifobuloq','Yuqori Machay',
      "O'rta Machay",'Qizilnavr','Pulhokim',"Dashtig'oz",
    ]),
    Tuman(id: 2, nomi: 'Sherobod tumani', markaz: 'Sherobod shahri', mahallalar: [
      'Guliston','Uzunsoy',"G'urjak-2","Qorabog'",'Qizilolma',"Zarabog'",
      "Uchyog'och",'Poshxurt','Vandob',"Chorbog'",'Nurtepa',"Kattabog'",'Oqtepa',
      'Galaguzar','Yoshlik',"Buyuk ipak yo'li","Qo'rg'on",'Bahor',"Ho'jgi",
      'Taroqli','Balxiguzar','Majnuntol','Qulluqsho',"G'urjak-1",'Kattahayot',
      "Do'stlik","G'ambur","Chag'atoy",'Boybuloq',"Cho'michli","Chuqurko'l",
      'Hakimobod','Navbur','Dehqonariq','Gulchinor','Mehnatobod','Qishloqbozor',
      "Xo'jaqiya-1",'Oyinli',"Xo'jaqiya-2",'Boyqishloq',"Bog'iobod",
      "Cho'yinchi",'Mehrobod','Istiqbol','Oltinvoha','Sherobod',
    ]),
    Tuman(id: 3, nomi: 'Muzrabot tumani', markaz: 'Muzrabot shahri', mahallalar: [
      'Duoba','Bodomzor','Madaniyat','Dehqonobod','Anorzor','Yakkatol',
      'Gulobod','Fidokor',"Buyuk ipak yo'li",'Yurtim jamoli','At-Termiziy',
      'Yangi diyor','Oriyat','Yangi er','Darband','Yangi hayot','Shaffof',
      'Mehnatobod','Nurli hayot','Sopollitepa',"Navro'z",'Olmazor','Alpomish',
      'Guliston',"Bog'i eram",'Fayziobod','Chegarachi','Mohiyat',
      'Muzrabot darvoza','Obod turmush','Obiyhayot','Mustaqillik',
      "Xalq yo'li",'Tong yulduzi','Mehrigiyoh',
    ]),
    Tuman(id: 4, nomi: 'Angor tumani', markaz: 'Angor shahri', mahallalar: [
      'Gilambob','Xomkon','Yuqori Tallimaron',"To'lqin",'Qorasuv','Gulzor',
      "Xo'janqon",'Yangiobod',"Ulug'bek",'Guliston',"Yuqori Xo'jaqiya",
      'Yuqori Tallashqon',"O'zbekiston","Navro'z",'Navbahor','Sharq guli',
      'Qadimiy Angor','Markaz','Kayran','Madaniyat',"Qo'shtegirmon",'Bahor',
      "Ilg'or","Qorabog'",'Farovon',"Do'stlik",'Navshahar','Chinobod','Zartepa',
      'Zang Gilambob','Tallashqon','Karvon','Qoraqir','Kattaqum',
      'Yangi hayot','Yangi turmush',
    ]),
    Tuman(id: 5, nomi: 'Termiz tumani', markaz: 'Termiz (tuman)', mahallalar: [
      'Orol','Xalqobod','Yangiobod','Nurafshon','Uchqizil','Yangi hayot',
      'Namuna','Mustaqillik','Sabzipoya','Guliston','Soliobod',"Navro'z",
      "Jo'yjangal",'Qoraxon','Termiz','Istiqlol','Quyoshliyurt',
      'Sharof Rashidov',"Do'stlik",'Amir Temur','Gulbahor','Ayritom',
      'At-Termiziy','Yangiyer','Kelajak','Bunyodkor',"Qo'ng'irot",
      'Qahramon','Nurli diyor','Muhiddin Eshtemirov',
    ]),
    Tuman(id: 6, nomi: 'Termiz shahri', markaz: 'Termiz', mahallalar: [
      "Temiryo'lchi",'Shifokor','Yulduz',"Kattabog'",'Bo\'ston','Jayhun',
      'Abdulla Avloniy','Alpomish',"Bog'ishamol","O'zbekiston","Navro'z",
      'Baynalmilal','Farhod',"Do'stlik",'Saxovat','Turon','Shodlik',
      'Eski shahar',"Bog'zor","Tuproqqo'rg'on",'Guliston',"Gulira'no",
      'Mehrobod','Surxon sohili',"Ma'rifat","Jo'yjangal",'Amu sohillari',
      'Majnuntol','Nurli kelajak','Abdurahmon Jomiy','Tinchlik',
      'Kokildor ota','Alisher Navoiy','Namuna','Chegara','Manguzar','Pattakesar',
    ]),
    Tuman(id: 7, nomi: "Jarqo'rg'on tumani", markaz: "Jarqo'rg'on shahri", mahallalar: [
      'Kamar','Yashnobod','Uzumzor','Obodguzar','Paxtaobod','Yoshlik',
      'Matonat','Janub qalqonlari','Neftchilar','Yangi qishloq','Mirzo Bobur',
      'Yangi usul','Yangi turmush',"Bobotog'",'Xalqobod','Mustaqillik',
      "Oftobqo'g'on",'Nurli diyor',"Qo'ldovli","Mirzo Ulug'bek",'Surxon sohili',
      'Istiqlol','Mehnat-rohat',"Do'stlik","Navro'z",'Yangiobod','Dam',
      'Paxtazavod','Soqchi','Qorabura','Namuna','Alisher Navoiy','Gulhovuz',
      'Zartepa',"Jarqo'rg'on minorasi",'Loyqand','Polvonlar yurti','Guliston',
      'Dehqonobod',"O'zbekiston","Qo'shtepa",'Qorayantoq','Qoraqursoq',
      'Hayitobod','Madaniyat','Mingchinor','Avlod','Markaziy Surxon',
      "O'rikli",'Maslahattepa','Oltintepa','Oqtepa','Obiyhayot',
      "G'urg'ur",'Ismoiltepa','Beshbuloq',
    ]),
    Tuman(id: 8, nomi: 'Qiziriq tumani', markaz: 'Qiziriq shahri', mahallalar: [
      'Gulobod','Qorasuv','Takiya','Zarobod','Xamkon',"Navro'z",'Yangiobod',
      'Tinchlik','Istiqlol','Yetimqum','Yangikent','Gilambob','Xalqobod',
      'Zartepa','Kunchiqish','Zarbdor','Qishloqazon','Shodlik','Rabotak',
      "Do'stlik",'Yangi turmush','Oqjar','Istara','Mustaqillik','Yangi hayot',
      'Karmaki','Yakkaterak',"Bog'iston","Bog'bonlar yurti",'Buyuk kelajak','Gulzor',
    ]),
    Tuman(id: 9, nomi: 'Bandixon tumani', markaz: 'Bandixon shahri', mahallalar: [
      'Bandixon','Bektepa','Saroy','Obod turmish','Polvontosh','Navbahor',
      'Chinor','Birdamlik','Paxtakor','Zevar',"Xo'jaipok","Bag'rikeng",
      'Obod yurt',"O'rg'ilsoy",'Farovon','Bahoriston',"Gulbog'","Qaldirg'och",
      'Limonzor',"Navro'z",'Quduqsoy','Obikor',
    ]),
    Tuman(id: 10, nomi: "Qumqo'rg'on tumani", markaz: "Qumqo'rg'on shahri", mahallalar: [
      'Arslonboyli','Achamoyli','Boymoqli',"Bobotog'",'Yangi qishloq','Arpapoya',
      "Xo'jaqishloq",'Xalqobod','Halaki','Istiqlol',"O'zbekiston 5 yilligi",
      'Yangi avlod','Bobolochin','Jaloyir','Uyas','Nurli diyor','Guliston',
      "Bo'ston",'Mustaqillik','Yangiyer','Paxtaobod',"Xo'jamulki",'Yuksalish',
      'Qarsoqli','Imomtepa','Navbahor',"To'g'on",'Jiydali','Beshqahramon',
      'Neftchi',"Do'stlik","Ulug'bek",'Surxon sohili','Yangi shahar','Azlarsoy',
      "Bog'aro",'Elobod','Hurriyat','Munchoqtepa','Hunarmandlar','Gultepa',
      'Mehrobod','Jarqishloq','Joziba',"G'alaba","To'da",'Sheroziy','Islomobod',
      "Cho'kirli",'Pastxam',"Kattako'l","Ko'ganli",'Tebat','Saxovat','Oqtom',
      'Yangiobod','Yangi hayot','Davlatsoy','Tayfang','Ariqoshgan','Umidni hollari',
    ]),
    Tuman(id: 11, nomi: "Sho'rchi tumani", markaz: "Sho'rchi shahri", mahallalar: [
      "Go'zallik",'Savurtepa','Hurlik','Qoraariq',"Oynako'l",'Bunyodkor',
      "Do'stlik",'Obodon','Shaldiroq','Katta Savur','Zarbdor',"Yoshg'ayrat",
      'Elbayon',"G'armaqo'rg'on","Bo'ston",'Alisher Navoiy','Ibn Sino',
      'Xushchekka','Ezgulik','Ozod','Tamshush','Laylakxona',"Navro'z",
      'Xayrobod',"Bobotog'",'Ko\'klam','Bobur','Yangi ariq',"To'la",
      'Olatemir',"Oqqo'rg'on",'Saksonkapa','Baxshtepa','Baxshtepa-1','Kakan',
      'Qoqaydi','Sovjironbobo','Joyilma','Oqkamar',"Yakkabog'",'Jarqishloq',
      'Tolli','Konobod',"Shakarko'l",'Oliyhimmat','Guliston','Yalti','Egarchi',
      'Oqtumshuq',"Qo'shtegirmon",'Oftobmakon','Tamaddun','Kushon',
    ]),
    Tuman(id: 12, nomi: 'Oltinsoy tumani', markaz: 'Oltinsoy shahri', mahallalar: [
      'Gulchechak','Qiziltepa','Barkamol avlod','Obod turmush',
      'Beshbola pahlavon',"Mustaqillikning 10 yilligi",'Qurama-1','Mirshodi',
      'Shoxcha','Yangi ariq','Xalqobod','Gulobod','Karsagan',"Xo'jaipok",
      'Oqarbuloq','Jilibuloq','Botosh','Shodlik','Bibizaynab',"Navro'z",
      'Madaniyat','Yangi qurilish','Jiyanbobo','Qoratepa','Guliston',
      "Bo'ston",'Qumpaykal','Qorliq','Ipoq','Chep','Jobu','Nurafshon',
      'Marmin',"Mo'minqul",'Obshir',"Tog'ay Murod",'Mingchinor','Pahlavon',
      'Sayrak','Xidirsho',"Dug'oba",'Ekraz','Shakarqamish','Yakkatut',
      'Olmazor',"To'xtamish",'Obod Vaxshivor','Katta Vaxshivor','Chinor',
      'Zardaqul','Sohibkor',
    ]),
    Tuman(id: 13, nomi: 'Sariosiyo tumani', markaz: 'Sariosiyo shahri', mahallalar: [
      'Sariosiyo','Markaziy','Gulbahor','Navbahor',"Do'stlik",'Mustaqillik',
      'Istiqlol','Mehnat','Yangi hayot',"Bog'ishamol","Navro'z",'Guliston',
      'Yangiobod','Madaniyat','Tinchlik',
    ]),
    Tuman(id: 14, nomi: 'Denov tumani', markaz: 'Denov shahri', mahallalar: [
      'Denov markazi',"Bog'ishamol","Do'stlik",'Gulbahor','Istiqlol',
      'Mustaqillik',"Navro'z",'Tinchlik','Yangi hayot','Yangi turmush',
      'Mehnat','Madaniyat',"Ulug'bek",'Amir Temur',"O'zbekiston",
      'Navbahor','Guliston','Eski shahar',"Qo'rg'on",'Sanoat',
    ]),
  ];

  static List<String> getMahallalar(int tumanId) =>
      tumanlar.firstWhere((t) => t.id == tumanId).mahallalar;

  static Tuman getTuman(int id) =>
      tumanlar.firstWhere((t) => t.id == id);

  static int get jamasiMahallalar =>
      tumanlar.fold(0, (s, t) => s + t.mahallalar.length);
}
