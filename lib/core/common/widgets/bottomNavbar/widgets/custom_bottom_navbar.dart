import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_images.dart';
import '../../../constants/texts.dart';
import '../controllers/bottom_nav_controller.dart';

class CustomBottomNavBar extends StatelessWidget {
  final BottomNavController navController = Get.find<BottomNavController>();

  CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B090A), // Dark grey background like barbershop
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Obx(
          () => BottomNavigationBar(
            currentIndex: navController.currentIndex.value,
            onTap: navController.changeIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF2C2C2E), // Match container
            selectedItemColor: Colors.white,
            unselectedItemColor: const Color(0xFF93938C),
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              color: Color(0xFF93938C),
            ),
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Image.asset(
                    AppImages.appLogo,
                    width: 24,
                    height: 24,
                    color: navController.currentIndex.value == 0
                        ? Colors.white
                        : const Color(0xFF93938C),
                  ),
                ),
                label: appTexts.beardCoins.tr,
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Image.asset(
                    AppImages.appLogo,
                    width: 24,
                    height: 24,
                    color: navController.currentIndex.value == 1
                        ? Colors.white
                        : const Color(0xFF93938C),
                  ),
                ),
                label: appTexts.barbershops.tr,
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Image.asset(
                    AppImages.appLogo,
                    width: 24,
                    height: 24,
                    color: navController.currentIndex.value == 2
                        ? Colors.white
                        : const Color(0xFF93938C),
                  ),
                ),
                label: appTexts.contest.tr,
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Image.asset(
                    AppImages.appLogo,
                    width: 24,
                    height: 24,
                    color: navController.currentIndex.value == 3
                        ? Colors.white
                        : const Color(0xFF93938C),
                  ),
                ),
                label: appTexts.shopping.tr,
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Image.asset(
                    AppImages.appLogo,
                    width: 24,
                    height: 24,
                    color: navController.currentIndex.value == 4
                        ? Colors.white
                        : const Color(0xFF93938C),
                  ),
                ),
                label: appTexts.profile.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
