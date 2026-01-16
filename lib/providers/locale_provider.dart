import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';
  Locale _locale = const Locale('tr'); // Varsayılan Türkçe

  Locale get locale => _locale;

  // Desteklenen diller
  static const List<Map<String, String>> supportedLocales = [
    {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
  ];

  LocaleProvider() {
    _loadLocale();
  }

  // SharedPreferences'tan dil tercihini yükle
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey) ?? 'tr';
    _locale = Locale(localeCode);
    notifyListeners();
  }

  // Dili değiştir ve kaydet
  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
  }

  // Mevcut dilin adını al
  String get currentLanguageName {
    final current = supportedLocales.firstWhere(
      (lang) => lang['code'] == _locale.languageCode,
      orElse: () => supportedLocales[0],
    );
    return current['name'] ?? 'Türkçe';
  }

  // Mevcut dilin bayrağını al
  String get currentLanguageFlag {
    final current = supportedLocales.firstWhere(
      (lang) => lang['code'] == _locale.languageCode,
      orElse: () => supportedLocales[0],
    );
    return current['flag'] ?? '🇹🇷';
  }
}
