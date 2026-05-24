import 'package:flutter/widgets.dart';
import '../di/service_locator.dart';
import 'hive_intialization.dart';
import 'stripe_initializer.dart';
import '../theme/theme_controller.dart';

class AppInitializer {
  static Future<void> initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();

    await HiveInitialization.initHive();

    setupServiceLocator();
    await ensureThemeController().loadThemeMode();
    await StripeInitializer.initStripe();

    // SocketService.initializeSocket(sl());
  }
}
