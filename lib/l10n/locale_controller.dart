import 'package:flutter/material.dart';

class LocaleController {
  static final ValueNotifier<Locale> locale =
      ValueNotifier(const Locale('uz'));

  static void setLocale(Locale value) {
    locale.value = value;
  }
}
