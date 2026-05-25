import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/common/widgets/app_scaffold.dart';
import '../../../../../core/theme/app_buttoms.dart';
import '../../../../../core/theme/app_colors.dart';
import '../controller/owner_create_event_controller.dart';
import '../widgets/create_event_fee_summary_card.dart';
import '../widgets/create_event_image_card.dart';
import '../widgets/create_event_input_field.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  late final OwnerCreateEventController _controller;

  Future<void> _showPaymentDecisionDialog() async {
    if (_controller.isSubmitting.value) return;

    final bool? shouldPayNow = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'Payment Confirmation',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
          content: Text(
            'Do you want to pay now and create this event?',
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    text: 'Cancel',
                    height: 42,
                    borderRadius: 8,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    height: 42,
                    borderRadius: 8,
                    child: Text(
                      'Pay Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldPayNow == true && mounted) {
      FocusScope.of(context).unfocus();
      await _controller.submitCreateEventWithPayment();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = ensureOwnerCreateEventController();
  }

  @override
  void dispose() {
    if (Get.isRegistered<OwnerCreateEventController>()) {
      Get.delete<OwnerCreateEventController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: true,
      backgroundColor: AppColors.background(context),
      appBarTitle: 'Create Event',
      centerTitle: false,
      bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      body: Obx(() {
        final bool isSubmitting = _controller.isSubmitting.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fill event details and publish instantly.',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 16),
            CreateEventImageCard(
              localImagePath: _controller.selectedImagePath.value,
              remoteImageUrl: _controller.responseImageUrl.value,
              onTap: _controller.pickImage,
            ),
            const SizedBox(height: 16),
            CreateEventInputField(
              label: 'Event Title',
              controller: _controller.titleController,
              hintText: 'My Event',
            ),
            const SizedBox(height: 12),
            CreateEventInputField(
              label: 'Description',
              controller: _controller.descriptionController,
              hintText: 'Write event description',
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CreateEventInputField(
                    label: 'Date',
                    controller: _controller.dateController,
                    hintText: 'MM/DD/YYYY',
                    readOnly: true,
                    onTap: () => _controller.pickDate(context),
                    suffixIcon: Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CreateEventInputField(
                    label: 'Time',
                    controller: _controller.timeController,
                    hintText: '6:00 PM',
                    readOnly: true,
                    onTap: () => _controller.pickTime(context),
                    suffixIcon: Icon(
                      Icons.access_time_outlined,
                      size: 20,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CreateEventInputField(
              label: 'Entry Fee',
              controller: _controller.entryFeeController,
              hintText: '100',
              prefixText: '\$ ',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 14),
            CreateEventFeeSummaryCard(
              platformServiceFee: _controller.platformServiceFee,
              total: _controller.total,
              onCompletePayment: _showPaymentDecisionDialog,
            ),
            const SizedBox(height: 14),
            if (_controller.createdEvent.value != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softCardColor(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.divider(context)),
                ),
                child: Text(
                  'Synced from API • ${_controller.createdEvent.value!.eventId}',
                  style: TextStyle(
                    color: AppColors.accentText(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            const SizedBox(height: 18),
            PrimaryButton(
              onPressed: _showPaymentDecisionDialog,
              height: 48,
              borderRadius: 10,
              isLoading: isSubmitting,
              child: Text(
                'Create Event',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
