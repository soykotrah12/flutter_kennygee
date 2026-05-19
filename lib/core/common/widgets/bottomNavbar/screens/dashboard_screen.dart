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
            height: 72,
            margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_controller.tabs.length, (index) {
                  final tab = _controller.tabs[index];
                  final isActive = _controller.currentIndex.value == index;
                  final isHighlighted = tab.isHighlighted;
                  final double iconContainerSize = isHighlighted
                      ? (isActive ? 38 : 46)
                      : (isActive ? 34 : 42);
                  final double iconSize = isHighlighted
                      ? (isActive ? 22 : 26)
                      : (isActive ? 20 : 24);

                  return GestureDetector(
                    onTap: () => _controller.changeIndex(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: isActive ? 12 : 0,
                      ),
                      height: 51,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryGreen
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(27),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: iconContainerSize,
                            height: iconContainerSize,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFF2ECE5)
                                  : AppColors.primaryGreen,
                              shape: BoxShape.circle,
                              border: isHighlighted && !isActive
                                  ? Border.all(
                                      color: const Color(0xFFF2ECE5),
                                      width: 1.2,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              isActive ? tab.activeIcon : tab.icon,
                              size: iconSize,
                              color: isActive
                                  ? AppColors.primaryGreen
                                  : Colors.white,
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  axis: Axis.horizontal,
                                  child: child,
                                ),
                              );
                            },
                            child: isActive
                                ? Padding(
                                    key: const ValueKey('label'),
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Center(
                                      child: Text(
                                        tab.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
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
