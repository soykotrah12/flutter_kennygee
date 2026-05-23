import 'package:flutter/widgets.dart';
import '../di/service_locator.dart';
import 'hive_intialization.dart';
import '../theme/theme_controller.dart';



class AppInitializer {
  static Future<void> initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();

    await HiveInitialization.initHive();

    setupServiceLocator();
    await ensureThemeController().loadThemeMode();

    // StripeInitializer.intiStripe();

    // SocketService.initializeSocket(sl());
  }
}
