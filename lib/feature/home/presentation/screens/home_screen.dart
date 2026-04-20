import 'package:flutter/material.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 380;
    final heroTitleSize = isCompact ? 30.0 : 40.0;
    final sectionTitleSize = isCompact ? 24.0 : 34.0;
    final sectionSubtitleSize = isCompact ? 12.0 : 14.0;
    final sectionCtaSize = isCompact ? 16.0 : 20.0;
    final eventTextSize = isCompact ? 16.0 : 18.0;
    final availableCardSpace = width - 32 - 12;
    final cardWidth = availableCardSpace > 0
        ? availableCardSpace / 2
        : width * 0.44;

    return AppScaffold(
      useSafeArea: true,
      isScrollable: true,
      backgroundColor: AppColors.appBackground,
      bodyPadding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            children: [
              Image.asset(
                AppImages.appLogo,
                width: 34,
                height: 50,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryWhite,
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: AppColors.primaryGreen, width: 1.2),
                ),
                child: const Icon(
                  Icons.translate,
                  color: AppColors.primaryGreen,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 44,
                padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.celebration_outlined, color: Colors.white),
                    SizedBox(width: isCompact ? 6 : 8),
                    Text(
                      'Events',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: eventTextSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Hungry? Discover What’s\nnearby.',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: heroTitleSize,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryGreen, width: 1.2),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'Search Restaurant, dishes...',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 52,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(9),
                    ),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(label: 'All', active: true),
              _FilterChip(label: 'Restaurant List'),
              _FilterChip(label: 'Food List'),
            ],
          ),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Nearby\nRestaurants',
            subtitle: '(within 10km)',
            titleSize: sectionTitleSize,
            subtitleSize: sectionSubtitleSize,
            ctaSize: sectionCtaSize,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 260,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _NearbyCard(width: cardWidth, image: AppImages.homeRestaurant1),
                const SizedBox(width: 12),
                _NearbyCard(width: cardWidth, image: AppImages.homeRestaurant2),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _OnlyTitleHeader(
            title: 'Recommended for you',
            titleSize: sectionTitleSize,
            ctaSize: sectionCtaSize,
          ),
          const SizedBox(height: 10),
          const _RecommendedItem(
            image: AppImages.homeRestaurant3,
            rating: '5.0',
          ),
          const SizedBox(height: 10),
          const _RecommendedItem(
            image: AppImages.homeRestaurant1,
            rating: '5.0',
          ),
          const SizedBox(height: 10),
          const _RecommendedItem(
            image: AppImages.homeRestaurant2,
            rating: '5.0',
          ),
          const SizedBox(height: 10),
          const _RecommendedItem(
            image: AppImages.homeRestaurant3,
            rating: '5.0',
          ),
          const SizedBox(height: 10),
          const _RecommendedItem(
            image: AppImages.homeRestaurant1,
            rating: '4.8',
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryGreen : AppColors.appBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryGreen),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textBlack,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.titleSize,
    required this.subtitleSize,
    required this.ctaSize,
  });

  final String title;
  final String subtitle;
  final double titleSize;
  final double subtitleSize;
  final double ctaSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Text(
          'See all',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: ctaSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _OnlyTitleHeader extends StatelessWidget {
  const _OnlyTitleHeader({
    required this.title,
    required this.titleSize,
    required this.ctaSize,
  });

  final String title;
  final double titleSize;
  final double ctaSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ),
        Text(
          'See all',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: ctaSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _NearbyCard extends StatelessWidget {
  const _NearbyCard({required this.width, required this.image});

  final double width;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.asset(
              image,
              height: 136,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Side view club',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.star, size: 15, color: AppColors.primaryOrange),
                SizedBox(width: 4),
                Text(
                  '5.0',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 15,
                  color: AppColors.primaryOrange,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '1.2 miles away',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_filled,
                  size: 15,
                  color: Color(0xFF2AB45D),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '11:00 AM - 10:00 PM',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedItem extends StatelessWidget {
  const _RecommendedItem({required this.image, required this.rating});

  final String image;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(image, width: 90, height: 90, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Side view club sandwich made...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 15,
                          color: AppColors.primaryOrange,
                        ),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Text(
                            '1.2 miles away',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textBlack,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors.primaryOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Icon(
                    Icons.access_time_filled,
                    size: 15,
                    color: Color(0xFF2AB45D),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '11:00 AM - 10:00 PM',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
