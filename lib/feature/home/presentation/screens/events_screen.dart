import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/home_event_controller.dart';
import '../../data/model/event_model.dart';
import '../navigation/home_navigation.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late final HomeEventController _eventController;
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _eventController = HomeEventController.ensureInitialized();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EventModel> _filterEvents(List<EventModel> events) {
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return events;

    return events.where((event) {
      return event.title.toLowerCase().contains(query) ||
          event.fee.toLowerCase().contains(query) ||
          event.date.toLowerCase().contains(query) ||
          event.time.toLowerCase().contains(query) ||
          event.location.toLowerCase().contains(query) ||
          event.detailsTitle.toLowerCase().contains(query) ||
          event.detailsDescription.toLowerCase().contains(query);
    }).toList();
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
        centerTitle: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hungry? Discover\nWhat\'s nearby',
              style: TextStyle(
                color: AppColors.primaryText(context),
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
                        ),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          fillColor: Colors.transparent,
                          filled: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          hintText: 'Search event name, price...',
                          hintStyle: TextStyle(
                            color: AppColors.secondaryText(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 64,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(10),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                        FocusScope.of(context).unfocus();
                      },
                      child: Center(
                        child: Image.asset(
                          AppImages.search,
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Limited Experiences',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upcoming Events Nearby',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final List<EventModel> events = _eventController.events;
              final List<EventModel> filteredEvents = _filterEvents(events);

              if (_eventController.isLoading.value && events.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                );
              }

              if (_eventController.error.value.isNotEmpty && events.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _eventController.error.value,
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                );
              }

              if (events.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No events available',
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                );
              }

              if (filteredEvents.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No matching events found',
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                );
              }

              return Column(
                children: List<Widget>.generate(filteredEvents.length, (index) {
                  final EventModel event = filteredEvents[index];

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == filteredEvents.length - 1 ? 0 : 16,
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
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
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
                        color: AppColors.softCardColor(context),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        event.fee,
                        style: TextStyle(
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
                      Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.secondaryText(context),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.date,
                          style: TextStyle(
                            color: AppColors.secondaryText(context),
                            fontSize: 20 / 2,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      Icon(
                        Icons.access_time,
                        color: AppColors.secondaryText(context),
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          event.time,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.secondaryText(context),
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
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 20 * 1.75 / 2,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.secondaryText(context),
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.secondaryText(context),
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
