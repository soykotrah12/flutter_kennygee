import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final controller = Get.put(SplashScreenController());

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo/Beard Icon
              SizedBox(
                height: screenHeight * 0.2,
                child: Image.asset(AppImages.appLogo, fit: BoxFit.contain),
              ),

              SizedBox(height: screenHeight * 0.02),

              // BARTFREUNDE Text
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: SizedBox(
                  child: Image.asset(
                    
                    AppImages.appLogo, fit: BoxFit.contain,
                    scale: screenWidth < 360 ? 1.5 : 1.0,
                  
                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
