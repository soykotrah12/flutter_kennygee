import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/subscription_plan_model.dart';
import '../controller/subscription_controller.dart';

class OwnerUpgradePlanScreen extends StatefulWidget {
  const OwnerUpgradePlanScreen({super.key});

  @override
  State<OwnerUpgradePlanScreen> createState() => _OwnerUpgradePlanScreenState();
}

class _OwnerUpgradePlanScreenState extends State<OwnerUpgradePlanScreen> {
  late final SubscriptionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ensureSubscriptionController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.softCardColor(context),
      child: AppScaffold(
        useSafeArea: true,
        isScrollable: false,
        backgroundColor: Colors.transparent,
        bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        customAppBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 72,
          titleSpacing: 0,
          automaticallyImplyLeading: true,
          title: Text(
            'Upgrade Plan',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Obx(() {
          if (_controller.isLoading.value && _controller.plans.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (_controller.plans.isEmpty) {
            return Center(
              child: Text(
                _controller.error.value.isNotEmpty
                    ? _controller.error.value
                    : 'No plans available',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: _controller.plans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 22),
            itemBuilder: (_, index) {
              final SubscriptionPlanModel plan = _controller.plans[index];
              return _PlanCard(plan: plan, highlighted: plan.isPopular);
            },
          );
        }),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.highlighted});

  final SubscriptionPlanModel plan;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = highlighted
        ? const Color(0xFFE2A522)
        : const Color(0xFF97BFB4);
    final Color badgeColor = highlighted
        ? const Color(0xFFD9B62B)
        : const Color(0xFF77C4B0);
    final Color surfaceColor = highlighted
        ? const Color(0xFFF3EEDC)
        : AppColors.softCardColor(context);
    final Color actionBg = highlighted
        ? AppColors.primaryGreen
        : const Color(0xFFEFF3F2);
    final Color actionText = highlighted
        ? Colors.white
        : AppColors.primaryGreen;
    final String badge = plan.badge.trim().isNotEmpty
        ? plan.badge
        : highlighted
        ? 'Most Popular'
        : 'Foundation';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.planName,
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: AppColors.primaryText(context)),
                  children: [
                    TextSpan(
                      text: '\$${plan.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Color(0xFF2E8166),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: '/${plan.duration}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFD3D3D3), height: 1),
              const SizedBox(height: 18),
              ...plan.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 22,
                        color:AppColors.primaryText(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            color: AppColors.primaryText(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: TextButton(
                  onPressed: () {
                    Get.snackbar(
                      'Plan Selected',
                      '${plan.planName} selected',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.cardColor(context),
                      margin: const EdgeInsets.all(12),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: actionBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppColors.primaryGreen,
                        width: 1.4,
                      ),
                    ),
                  ),
                  child: Text(
                    'Buy Plan',
                    style: TextStyle(
                      color: actionText,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -1,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(minWidth: 160),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                border: Border.all(
                  color: highlighted
                      ? AppColors.primaryGreen
                      : Colors.transparent,
                  width: highlighted ? 1.2 : 0,
                ),
              ),
              child: Text(
                badge,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
