import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/ai_chat_restaurant_model.dart';

class RestaurantRecommendationCard extends StatelessWidget {
  const RestaurantRecommendationCard({super.key, required this.restaurant});

  final AiChatRestaurantModel restaurant;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: _RestaurantImage(imageUrl: restaurant.imageUrl),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      restaurant.cuisine?.isNotEmpty == true
                          ? restaurant.cuisine!
                          : (restaurant.description.isNotEmpty
                                ? restaurant.description
                                : 'Restaurant'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    if (restaurant.address.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          restaurant.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.secondaryText(context),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6E389),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '\u2605 ${_ratingLabel(restaurant.rating)}',
                  style: TextStyle(
                    color: Color(0xFF2F2F2F),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoChip(
                icon: Icons.location_on,
                text: restaurant.distance?.isNotEmpty == true
                    ? restaurant.distance!
                    : '0.8 km',
              ),
              const SizedBox(width: 7),
              _InfoChip(
                icon: Icons.attach_money,
                text: restaurant.priceLabel?.isNotEmpty == true
                    ? restaurant.priceLabel!
                    : '\$\$',
              ),
              const SizedBox(width: 7),
              _InfoChip(
                icon: Icons.access_time,
                text: restaurant.openingHours?.isNotEmpty == true
                    ? restaurant.openingHours!
                    : 'N/A',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _ratingLabel(double? rating) {
    if (rating == null) return '5.0';
    return rating.toStringAsFixed(1);
  }
}

class _RestaurantImage extends StatelessWidget {
  const _RestaurantImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return Container(
        width: 36,
        height: 36,
        color: AppColors.softCardColor(context),
        alignment: Alignment.center,
        child: Icon(
          Icons.storefront_outlined,
          size: 18,
          color: AppColors.secondaryText(context),
        ),
      );
    }

    return Image.network(
      imageUrl,
      width: 36,
      height: 36,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          width: 36,
          height: 36,
          color: AppColors.softCardColor(context),
          alignment: Alignment.center,
          child: Icon(
            Icons.storefront_outlined,
            size: 18,
            color: AppColors.secondaryText(context),
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.secondaryText(context)),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
