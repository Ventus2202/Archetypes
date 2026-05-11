import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants.dart';

class SettingsNotifier extends Notifier<({ThemeMode themeMode, Locale locale})> {
  late Box _box;

  @override
  ({ThemeMode themeMode, Locale locale}) build() {
    _box = Hive.box(kHiveBoxSettings);
    final themeIndex = _box.get(kHiveKeyThemeMode, defaultValue: 0) as int;
    final localeTag = _box.get(kHiveKeyLocale, defaultValue: 'it') as String;
    return (
      themeMode: ThemeMode.values[themeIndex],
      locale: Locale(localeTag),
    );
  }

  void setThemeMode(ThemeMode mode) {
    _box.put(kHiveKeyThemeMode, mode.index);
    state = (themeMode: mode, locale: state.locale);
  }

  void setLocale(Locale locale) {
    _box.put(kHiveKeyLocale, locale.languageCode);
    state = (themeMode: state.themeMode, locale: locale);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, ({ThemeMode themeMode, Locale locale})>(
  SettingsNotifier.new,
);

final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(settingsProvider).themeMode,
);

final localeProvider = Provider<Locale>(
  (ref) => ref.watch(settingsProvider).locale,
);
