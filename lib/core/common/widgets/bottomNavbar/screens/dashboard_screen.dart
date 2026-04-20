import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../feature/auth/presentation/controller/auth_flow_controller.dart';
import '../../../../theme/app_colors.dart';
import '../controllers/bottom_nav_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.role});

  final AppUserRole role;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final String _tag;
  late final BottomNavController _controller;

  @override
  void initState() {
    super.initState();
    _tag = 'dashboard_${widget.role.storageValue}';
    _controller = Get.put(BottomNavController(role: widget.role), tag: _tag);
  }

  @override
  void dispose() {
    Get.delete<BottomNavController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _controller.onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.appBackground,
        body: Obx(
          () => IndexedStack(
            index: _controller.currentIndex.value,
            children: List.generate(_controller.tabs.length, (index) {
              return Navigator(
                key: _controller.navigatorKeys[index],
                onGenerateRoute: (settings) => MaterialPageRoute(
                  builder: (_) => _controller.tabs[index].screen,
                ),
              );
            }),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            height: 86,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Obx(
              () => Row(
                children: List.generate(_controller.tabs.length, (index) {
                  final tab = _controller.tabs[index];
                  final isActive = _controller.currentIndex.value == index;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 54,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryGreen
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(27),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(27),
                        onTap: () => _controller.changeIndex(index),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: isActive ? 34 : 42,
                              height: isActive ? 34 : 42,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFFF2ECE5)
                                    : AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isActive ? tab.activeIcon : tab.icon,
                                size: isActive ? 20 : 24,
                                color: isActive
                                    ? AppColors.primaryGreen
                                    : Colors.white,
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  tab.label,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
