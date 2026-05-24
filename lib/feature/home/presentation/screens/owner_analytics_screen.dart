import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/owner_analytics_model.dart';
import '../controller/owner_analytics_controller.dart';

class OwnerAnalyticsScreen extends StatefulWidget {
  const OwnerAnalyticsScreen({super.key});

  @override
  State<OwnerAnalyticsScreen> createState() => _OwnerAnalyticsScreenState();
}

class _OwnerAnalyticsScreenState extends State<OwnerAnalyticsScreen> {
  late final OwnerAnalyticsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ensureOwnerAnalyticsController();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.background(context),
      bodyPadding: const EdgeInsets.fromLTRB(16, 52, 16, 24),
      body: Obx(() {
        final OwnerAnalyticsModel? analytics = _controller.analytics.value;

        if (_controller.isLoading.value && analytics == null) {
          return RefreshIndicator(
            onRefresh: _controller.fetchAnalytics,
            color: AppColors.primaryGreen,
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 36),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (_controller.error.value.isNotEmpty && analytics == null) {
          return RefreshIndicator(
            onRefresh: _controller.fetchAnalytics,
            color: AppColors.primaryGreen,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Column(
                    children: [
                      Text(
                        _controller.error.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _controller.fetchAnalytics,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (analytics == null) {
          return RefreshIndicator(
            onRefresh: _controller.fetchAnalytics,
            color: AppColors.primaryGreen,
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(
                    child: Text(
                      'No analytics found',
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.fetchAnalytics,
          color: AppColors.primaryGreen,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [_AnalyticsBody(analytics: analytics)],
          ),
        );
      }),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({required this.analytics});

  final OwnerAnalyticsModel analytics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
          style: TextStyle(
            color: AppColors.secondaryText(context),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Real-time Visibility',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 20,
            height: 0.95,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 16),
        _LargeMetricCard(
          icon: Icons.remove_red_eye_outlined,
          iconBgColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkCardSoft
              : const Color(0xFFD7ECE0),
          iconColor: AppColors.primaryGreen,
          trailingText:
              '${analytics.profileViewsChangePercent >= 0 ? '+' : ''}${_formatCompactDecimal(analytics.profileViewsChangePercent)}%',
          trailingColor: const Color(0xFF24C05A),
          valueText: _formatWholeNumber(analytics.profileViews),
          subtitle: 'Profile Views ${analytics.profileViewsLabel}'.trim(),
        ),
        const SizedBox(height: 14),
        _LargeMetricCard(
          icon: Icons.search_rounded,
          iconBgColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkCardSoft
              : const Color(0xFFF2EFE3),
          iconColor: const Color(0xFFC89A1A),
          trailingText: analytics.searchAppearancesLabel,
          trailingColor: AppColors.primaryGreen,
          valueText: _formatWholeNumber(analytics.searchAppearances),
          subtitle: 'Search Appearances',
        ),
        const SizedBox(height: 18),
        Text(
          'Engagement Depth',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SmallMetricCard(
                icon: Icons.restaurant_menu,
                iconColor: const Color(0xFF0A3E76),
                title: 'Menu Views',
                value: _formatWholeNumber(analytics.menuViews),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SmallMetricCard(
                icon: Icons.favorite,
                iconColor: const Color(0xFF966400),
                title: 'Saves',
                value: _formatWholeNumber(analytics.saves),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Rating Consistency',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            Image.asset(AppImages.starIcon, width: 18, height: 18),
            const SizedBox(width: 10),
            Text(
              analytics.currentRating.toStringAsFixed(1),
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          analytics.ratingSubtitle.trim().isEmpty
              ? '30-day historical trend'
              : analytics.ratingSubtitle,
          style: TextStyle(
            color: AppColors.secondaryText(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 10),
        _RatingTrendCard(points: analytics.ratingTrend),
        const SizedBox(height: 18),
        Text(
          'Most Search Foods',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 10),
        if (analytics.mostSearchFoods.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow(context, light: 0.07, dark: 0.22),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'No search food analytics available.',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
          )
        else
          Column(
            children: List<Widget>.generate(analytics.mostSearchFoods.length, (
              int index,
            ) {
              final MostSearchFoodModel food = analytics.mostSearchFoods[index];
              final String imagePath = _foodPlaceholder(index);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == analytics.mostSearchFoods.length - 1
                      ? 0
                      : 12,
                ),
                child: _MostSearchFoodCard(food: food, imagePath: imagePath),
              );
            }),
          ),
        const SizedBox(height: 18),
        Text(
          'Estimated Arrival Traffic',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 10),
        _EstimatedArrivalTrafficCard(
          traffic: analytics.estimatedArrivalTraffic,
        ),
      ],
    );
  }

  String _foodPlaceholder(int index) {
    const List<String> placeholders = <String>[
      AppImages.homeRestaurant1,
      AppImages.homeRestaurant2,
      AppImages.homeRestaurant3,
    ];

    return placeholders[index % placeholders.length];
  }
}

class _LargeMetricCard extends StatelessWidget {
  const _LargeMetricCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.trailingText,
    required this.trailingColor,
    required this.valueText,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String trailingText;
  final Color trailingColor;
  final String valueText;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context, light: 0.07, dark: 0.22),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 24, color: iconColor),
              ),
              const Spacer(),
              Text(
                trailingText,
                style: TextStyle(
                  color: trailingColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            valueText,
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 32,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallMetricCard extends StatelessWidget {
  const _SmallMetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.softCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingTrendCard extends StatelessWidget {
  const _RatingTrendCard({required this.points});

  final List<OwnerAnalyticsTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.softCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: CustomPaint(
        painter: _TrendChartPainter(
          points: points,
          gridColor: AppColors.divider(context),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({required this.points, required this.gridColor});

  final List<OwnerAnalyticsTrendPoint> points;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPadding = 34;
    const double rightPadding = 10;
    const double topPadding = 16;
    const double bottomPadding = 20;

    final double chartWidth = size.width - leftPadding - rightPadding;
    final double chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    const TextStyle labelStyle = TextStyle(
      color: AppColors.primaryGreen,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      fontFamily: 'Montserrat',
    );

    final List<double> yTicks = <double>[5, 4, 3, 2, 1];

    for (final double tick in yTicks) {
      final double y = topPadding + ((5 - tick) / 4) * chartHeight;

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(leftPadding + chartWidth, y),
        gridPaint,
      );

      final TextPainter painter = TextPainter(
        text: TextSpan(text: tick.toInt().toString(), style: labelStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();

      painter.paint(canvas, Offset(8, y - painter.height / 2));
    }

    final List<double> values = points.isEmpty
        ? <double>[1, 1, 1, 1, 1]
        : points.map((point) {
            if (point.value <= 0) return 1.0;
            return point.value.clamp(1.0, 5.0);
          }).toList();

    final Path linePath = Path();

    for (int i = 0; i < values.length; i++) {
      final double x = values.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding + (i / (values.length - 1)) * chartWidth;
      final double normalized = (values[i] - 1) / 4;
      final double y = topPadding + chartHeight - (normalized * chartHeight);

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    final Paint linePaint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    if (oldDelegate.gridColor != gridColor) return true;
    if (oldDelegate.points.length != points.length) return true;

    for (int i = 0; i < points.length; i++) {
      if (oldDelegate.points[i].value != points[i].value ||
          oldDelegate.points[i].date != points[i].date) {
        return true;
      }
    }

    return false;
  }
}

class _MostSearchFoodCard extends StatelessWidget {
  const _MostSearchFoodCard({required this.food, required this.imagePath});

  final MostSearchFoodModel food;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final String growth = _formatSignedPercent(food.demandGrowth);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context, light: 0.07, dark: 0.22),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AdaptiveImage(
              path: imagePath,
              width: 112,
              height: 92,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.title.trim().isEmpty ? 'Untitled Food' : food.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  food.subtitle.trim().isEmpty
                      ? 'Food category'
                      : food.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                growth,
                style: TextStyle(
                  color: Color(0xFF24C05A),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Demand\nGrowth',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EstimatedArrivalTrafficCard extends StatelessWidget {
  const _EstimatedArrivalTrafficCard({required this.traffic});

  final EstimatedArrivalTrafficModel traffic;

  @override
  Widget build(BuildContext context) {
    final int maxCustomers = traffic.hourlyTraffic.fold<int>(
      0,
      (int previousValue, HourlyTrafficPointModel element) =>
          element.customers > previousValue ? element.customers : previousValue,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context, light: 0.07, dark: 0.22),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkCardSoft
                      : const Color(0xFFE9F5EE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  traffic.currentHour.trim().isEmpty
                      ? 'Current hour unavailable'
                      : traffic.currentHour,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              Text(
                '${_formatWholeNumber(traffic.activeCustomersEstimate)} active',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SmallMetricCard(
                  icon: Icons.group_outlined,
                  iconColor: const Color(0xFF0A3E76),
                  title: 'Current Estimate',
                  value: _formatWholeNumber(traffic.activeCustomersEstimate),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallMetricCard(
                  icon: Icons.schedule_rounded,
                  iconColor: const Color(0xFFC89A1A),
                  title: 'Next Hour',
                  value: _formatWholeNumber(traffic.nextHourEstimate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Hourly Traffic',
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 10),
          if (traffic.hourlyTraffic.isEmpty)
            Text(
              'No hourly traffic data available.',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            )
          else
            SizedBox(
              height: 130,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: traffic.hourlyTraffic.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int index) {
                  final HourlyTrafficPointModel point =
                      traffic.hourlyTraffic[index];

                  return _HourlyTrafficBar(
                    hourLabel: _formatHourLabel(point.hour),
                    customers: point.customers,
                    maxCustomers: maxCustomers,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _HourlyTrafficBar extends StatelessWidget {
  const _HourlyTrafficBar({
    required this.hourLabel,
    required this.customers,
    required this.maxCustomers,
  });

  final String hourLabel;
  final int customers;
  final int maxCustomers;

  @override
  Widget build(BuildContext context) {
    const double minBarHeight = 6;
    const double maxBarHeight = 66;
    final double ratio = maxCustomers <= 0 ? 0 : customers / maxCustomers;
    final double barHeight = maxCustomers <= 0
        ? minBarHeight
        : (minBarHeight + ((maxBarHeight - minBarHeight) * ratio)).clamp(
            minBarHeight,
            maxBarHeight,
          );

    return SizedBox(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            _formatWholeNumber(customers),
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 16,
            height: barHeight,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hourLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

String _formatWholeNumber(int value) {
  return NumberFormat.decimalPattern().format(value);
}

String _formatCompactDecimal(double value) {
  if (value % 1 == 0) {
    return value.toStringAsFixed(0);
  }

  return value.toStringAsFixed(1);
}

String _formatSignedPercent(double value) {
  final String sign = value >= 0 ? '+' : '-';
  final double absoluteValue = value.abs();
  final String formatted = absoluteValue % 1 == 0
      ? absoluteValue.toStringAsFixed(0)
      : absoluteValue.toStringAsFixed(1);
  return '$sign$formatted%';
}

String _formatHourLabel(int hour) {
  final DateTime time = DateTime(2026, 1, 1, hour.clamp(0, 23));
  return DateFormat('ha').format(time).toLowerCase();
}
