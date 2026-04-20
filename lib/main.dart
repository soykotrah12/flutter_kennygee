import 'package:flutter/material.dart';
import 'package:flutter_kennegee/core/common/widgets/bottomNavbar/screens/dashboard_screen.dart';
import 'package:get/get.dart';
import 'core/init/app_initializer.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppInitializer.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'kennygee',
      theme: AppTheme.light,
      home: const DashboardScreen(),
    );
  }
}