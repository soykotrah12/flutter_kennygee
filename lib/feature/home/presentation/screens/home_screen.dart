import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/constants/feature_colors.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: FeatureColors.homeBackground,
      useSafeArea: true,
      isScrollable: true,
      body: Column(
        children: [
        
        ],
      ),
    );
  }
}
