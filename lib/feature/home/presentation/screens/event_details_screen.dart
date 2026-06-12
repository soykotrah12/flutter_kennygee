import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/login_required_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../payment/presentation/controllers/payment_controller.dart';
import '../../data/model/event_model.dart';
import '../controller/home_event_details_controller.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({required this.event, super.key});

  final EventModel event;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late final HomeEventDetailsController detailsController;
  late final PaymentController paymentController;
  late final String controllerTag;

  Future<bool> _showJoinPaymentDialog(EventModel event) async {
    final bool? shouldPay = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'Confirm Payment',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title.trim().isNotEmpty ? event.title : 'Event',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Entry fee: ${event.fee.trim().isNotEmpty ? event.fee : 'N/A'}',
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Pay Now',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        );
      },
    );

    return shouldPay == true;
  }

  @override
  void initState() {
    super.initState();
    controllerTag = HomeEventDetailsController.tagForEvent(widget.event.id);

    if (Get.isRegistered<HomeEventDetailsController>(tag: controllerTag)) {
      Get.delete<HomeEventDetailsController>(tag: controllerTag, force: true);
    }

    detailsController = HomeEventDetailsController.ensureInitialized(
      widget.event.id,
    );
    paymentController = ensurePaymentController();

    detailsController.fetchEventDetails(widget.event.id);
  }

  @override
  void dispose() {
    if (Get.isRegistered<HomeEventDetailsController>(tag: controllerTag)) {
      Get.delete<HomeEventDetailsController>(tag: controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.rolebackground),
          fit: BoxFit.cover,
        ),
      ),
      child: AppScaffold(
        useSafeArea: true,
        isScrollable: true,
        backgroundColor: Colors.transparent,
        bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        appBarTitle: 'Events for you',
        body: Obx(() {
          if (detailsController.isLoading.value &&
              detailsController.event.value == null) {
            return Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            );
          }

          if (detailsController.error.value.isNotEmpty &&
              detailsController.event.value == null) {
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    detailsController.error.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      detailsController.fetchEventDetails(widget.event.id);
                    },
                    child: Text(
                      'Retry',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final EventModel activeEvent =
              detailsController.event.value ?? widget.event;
          final bool going = detailsController.isGoing.value;
          final bool isLoadingGoing = detailsController.isLoadingGoing.value;
          final bool hasGoingStatus = detailsController.hasGoingStatus.value;
          final bool isToggleLoading = detailsController.isToggleLoading.value;
          final bool isPaymentLoading =
              paymentController.isPaymentLoading.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AdaptiveImage(
                  path: activeEvent.image,
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _InfoBox(
                      icon: AppImages.date,
                      title: 'DATE',
                      value: activeEvent.date,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _InfoBox(
                      icon: AppImages.time,
                      title: 'TIME',
                      value: activeEvent.time,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _InfoBox(
                icon: AppImages.entryfee,
                title: 'Entry Fee',
                value: activeEvent.fee,
                isWide: true,
              ),
              const SizedBox(height: 34),
              Text(
                activeEvent.detailsTitle,
                style: TextStyle(
                  color: AppColors.accentText(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                activeEvent.detailsDescription,
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 16,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 30),
              InkWell(
                onTap:
                    isToggleLoading ||
                        isLoadingGoing ||
                        !hasGoingStatus ||
                        isPaymentLoading
                    ? null
                    : () async {
                        final bool canContinue = await requireLoginForFeature(
                          featureName: 'event joining and payments',
                        );
                        if (!canContinue) return;

                        final bool wasGoing = going;

                        if (!going) {
                          final bool shouldPay = await _showJoinPaymentDialog(
                            activeEvent,
                          );

                          if (!shouldPay) return;

                          final bool paymentSuccess = await paymentController
                              .payForOrder(orderId: activeEvent.id);

                          if (!paymentSuccess) {
                            Get.snackbar(
                              'Payment',
                              paymentController.paymentMessage.value.isNotEmpty
                                  ? paymentController.paymentMessage.value
                                  : 'Payment was not completed.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.black87,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(12),
                            );
                            return;
                          }

                          Get.snackbar(
                            'Payment',
                            paymentController.paymentMessage.value.isNotEmpty
                                ? paymentController.paymentMessage.value
                                : 'Payment successful.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(12),
                          );
                        }

                        final String message = await detailsController
                            .toggleGoing(activeEvent.id);

                        if (!wasGoing && detailsController.isGoing.value) {
                          Get.snackbar(
                            'Event',
                            'You are enrolled for this event.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(12),
                          );
                          if (Get.key.currentState?.canPop() ?? false) {
                            await Future<void>.delayed(
                              const Duration(milliseconds: 180),
                            );
                            Get.back();
                          }
                          return;
                        }

                        if (message.isNotEmpty) {
                          Get.snackbar(
                            'Event',
                            message,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(12),
                          );
                        }
                      },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: going ? AppColors.red : AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: isToggleLoading || isPaymentLoading || !hasGoingStatus
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          going ? 'Cancel' : activeEvent.actionLabel,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.title,
    required this.value,
    this.isWide = false,
  });

  final String icon;
  final String title;
  final String value;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: isWide ? 18 : 14),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 2,
            spreadRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(icon, width: 24, height: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}
