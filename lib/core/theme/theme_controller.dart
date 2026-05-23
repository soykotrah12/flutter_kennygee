import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../network/constants/cache_constants.dart';

class ThemeController extends GetxController {
  ThemeController({Box<dynamic>? settingsBox})
    : _settingsBox =
          settingsBox ?? Hive.box<dynamic>(ApiCacheConstants.settingsCacheKey);

  static const String _darkModeKey = 'is_dark_mode';
  final Box<dynamic> _settingsBox;

  final RxBool isDarkMode = false.obs;

  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadThemeMode() async {
    final bool storedValue = _settingsBox.get(_darkModeKey, defaultValue: false);
    isDarkMode.value = storedValue;
  }

  Future<void> toggleDarkMode(bool value) async {
    if (isDarkMode.value == value) {
      return;
    }
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    await _settingsBox.put(_darkModeKey, value);
  }
}

ThemeController ensureThemeController() {
  if (Get.isRegistered<ThemeController>()) {
    return Get.find<ThemeController>();
  }
  return Get.put(ThemeController(), permanent: true);
}
