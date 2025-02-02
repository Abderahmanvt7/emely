import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('fr'); // Default is French

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['ar', 'fr'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners(); // This triggers UI updates
  }
}
