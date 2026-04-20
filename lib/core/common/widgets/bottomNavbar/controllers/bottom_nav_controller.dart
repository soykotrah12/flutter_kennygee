import 'package:get/get.dart';

class BottomNavController extends GetxController {
  var currentIndex = 0.obs;

  BottomNavController() {
    // Explicitly set to 0 on creation
    currentIndex.value = 0;
    print('BottomNavController initialized with index: ${currentIndex.value}');
  }

  void changeIndex(int index) {
    currentIndex.value = index;
    print('Nav index changed to: $index');
    refreshDataForIndex(index);
  }

  void refreshDataForIndex(int index) {
    // switch (index) {
    //   case 0: // MemberHome
    //     if (Get.isRegistered<MemberHomeController>()) {
    //       Get.find<MemberHomeController>().fetchUserData();
    //     }
    //     break;
    //   case 1: // Barbershop
    //     if (Get.isRegistered<BarbershopController>()) {
    //       Get.find<BarbershopController>().fetchAllBarbers();
    //     }
    //     break;
    //   case 2: // Contest
    //     if (Get.isRegistered<ContestController>()) {
    //       Get.find<ContestController>().refreshContest();
    //     }
    //     break;
    //   case 3: // Shop (Under construction)
    //     break;
    //   case 4: // Profile
    //     if (Get.isRegistered<ProfileController>()) {
    //       Get.find<ProfileController>().fetchProfile();
    //     }
    //     break;
    // }
  }

  /// Reset to home screen (index 0)
  void resetToHome() {
    currentIndex.value = 0;
    print('Reset to Home screen (index 0)');
    refreshDataForIndex(0);
  }
}
