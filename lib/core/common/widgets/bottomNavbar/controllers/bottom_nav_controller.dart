import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../feature/auth/presentation/controller/auth_flow_controller.dart';
import '../../../../../feature/home/presentation/screens/favorite_screen.dart';
import '../../../../../feature/home/presentation/screens/home_screen.dart';
import '../../../../../feature/home/presentation/screens/owner_analytics_screen.dart';
import '../../../../../feature/home/presentation/screens/owner_home_screen.dart';
import '../../../../../feature/home/presentation/screens/owner_shop_screen.dart';
import '../../../../../feature/profile/presentation/screens/profile_screen.dart';
import '../../../../theme/app_colors.dart';

class BottomNavController extends GetxController {
  BottomNavController({required this.role});

  final AppUserRole role;

  final RxInt currentIndex = 0.obs;

  late final List<DashboardTabItem> tabs = role.isOwner
      ? [
          const DashboardTabItem(
            label: 'Home',
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            screen: OwnerHomeScreen(),
          ),
          const DashboardTabItem(
            label: 'Location',
            icon: Icons.location_on_outlined,
            activeIcon: Icons.location_on,
            screen: DashboardPlaceholderView(
              title: 'Restaurant Location',
              subtitle: 'Manage your outlet location and delivery zone.',
              icon: Icons.map_outlined,
            ),
          ),
          const DashboardTabItem(
            label: 'Store',
            icon: Icons.storefront_outlined,
            activeIcon: Icons.storefront,
            screen: OwnerShopScreen(),
          ),
          const DashboardTabItem(
            label: 'Analytics',
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart,
            screen: OwnerAnalyticsScreen(),
          ),
        ]
      : [
          const DashboardTabItem(
            label: 'Home',
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            screen: HomeScreen(),
          ),
          const DashboardTabItem(
            label: 'Location',
            icon: Icons.location_on_outlined,
            activeIcon: Icons.location_on,
            screen: DashboardPlaceholderView(
              title: 'Nearby On Map',
              subtitle: 'Explore all nearby restaurants around you.',
              icon: Icons.map_outlined,
            ),
          ),
          const DashboardTabItem(
            label: 'Favorite',
            icon: Icons.favorite_outline,
            activeIcon: Icons.favorite,
            screen: FavoriteScreen(),
          ),
          const DashboardTabItem(
            label: 'Profile',
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            screen: ProfileScreen(),
          ),
        ];

  late final List<GlobalKey<NavigatorState>> navigatorKeys = List.generate(
    tabs.length,
    (index) => GlobalKey<NavigatorState>(),
  );

  void changeIndex(int index) {
    if (index == currentIndex.value) {
      navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    currentIndex.value = index;
  }

  Future<bool> onWillPop() async {
    final currentNavigator = navigatorKeys[currentIndex.value].currentState;
    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
      return false;
    }

    if (currentIndex.value != 0) {
      currentIndex.value = 0;
      return false;
    }

    return true;
  }
}

class DashboardTabItem {
  const DashboardTabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;
}

class DashboardPlaceholderView extends StatelessWidget {
  const DashboardPlaceholderView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.primaryGreen),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textBlack,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
