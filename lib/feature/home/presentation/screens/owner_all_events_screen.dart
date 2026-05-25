import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/event_model.dart';
import '../controller/owner_shop_event_controller.dart';
import '../widgets/event_card.dart';

class OwnerAllEventsScreen extends StatefulWidget {
  const OwnerAllEventsScreen({super.key});

  @override
  State<OwnerAllEventsScreen> createState() => _OwnerAllEventsScreenState();
}

class _OwnerAllEventsScreenState extends State<OwnerAllEventsScreen> {
  late final OwnerShopEventController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ensureOwnerShopEventController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchOwnerEvents();
    });
  }

  String _friendlyError(String raw) {
    final String message = raw.trim();
    if (message.isEmpty) return 'Unable to load events right now.';
    if (message.startsWith('{') || message.startsWith('[')) {
      return 'Unable to load events right now. Please try again.';
    }
    return message;
  }

  EventModel _eventWithImageFallback(EventModel event) {
    if (event.image.trim().isNotEmpty) return event;
    return EventModel(
      id: event.id,
      title: event.title,
      image: AppImages.homeRestaurant1,
      date: event.date,
      time: event.time,
      fee: event.fee,
      location: event.location,
      detailsTitle: event.detailsTitle,
      detailsDescription: event.detailsDescription,
      actionLabel: event.actionLabel,
      isGoing: event.isGoing,
      goingUsers: event.goingUsers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.background(context),
      appBarTitle: 'All Events',
      centerTitle: false,
      bodyPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      body: Obx(() {
        final List<EventModel> events = _controller.events;
        final bool isLoading = _controller.isLoading.value;
        final String error = _controller.error.value;

        if (isLoading && events.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (events.isEmpty && error.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _friendlyError(error),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _controller.fetchOwnerEvents,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accentText(context),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (events.isEmpty) {
          return Center(
            child: Text(
              'No events found yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.fetchOwnerEvents,
          color: AppColors.primaryGreen,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final EventModel event = _eventWithImageFallback(events[index]);
              return OwnerEventCard(event: event);
            },
          ),
        );
      }),
    );
  }
}
