import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/home_event_controller.dart';
import '../../data/model/event_model.dart';
import '../navigation/home_navigation.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeEventController eventController =
        HomeEventController.ensureInitialized();

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
        centerTitle: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hungry? Discover\nWhat\'s nearby',
              style: TextStyle(
                color: AppColors.textBlack,
                fontSize: 22,
                height: 1.25,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 18),
            Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGreen, width: 1.4),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Search Restaurant, dishes...',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 64,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(10),
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        AppImages.search,
                        width: 26,
                        height: 26,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Limited Experiences',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upcoming Events Nearby',
              style: TextStyle(
                color: AppColors.textBlack,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final List<EventModel> events = eventController.events;

              if (eventController.isLoading.value && events.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                );
              }

              if (eventController.error.value.isNotEmpty && events.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    eventController.error.value,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                );
              }

              if (events.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No events found',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                );
              }

              return Column(
                children: List<Widget>.generate(events.length, (index) {
                  final EventModel event = events[index];

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == events.length - 1 ? 0 : 16,
                    ),
                    child: _EventCard(
                      event: event,
                      onTap: () => HomeNavigation.openEventDetails(event),
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, this.onTap});

  final EventModel event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  AdaptiveImage(
                    path: event.image,
                    width: double.infinity,
                    height: 202,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        event.fee,
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.textGrey,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.date,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 20 / 2,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.access_time,
                        color: AppColors.textGrey,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          event.time,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 20 / 2,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 20 * 1.75 / 2,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.textGrey,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 17 * 1.2 / 2,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
