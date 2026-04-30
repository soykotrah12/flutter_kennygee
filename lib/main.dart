import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'feature/auth/presentation/screens/splash_screen.dart';
import 'core/init/app_initializer.dart';
import 'core/theme/app_theme.dart';
import 'core/common/widgets/system_nav_bar_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hide system bottom navigation on startup
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );
  
  await AppInitializer.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SystemNavBarHandler(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Renbite',
        theme: AppTheme.light,
        home: SplashScreen(),
      ),
    );
  }
}
