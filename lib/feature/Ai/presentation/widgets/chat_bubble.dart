import 'package:flutter/material.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/ai_chat_controller.dart';
import 'restaurant_recommendation_card.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.userAvatarUrl,
  });

  final AiChatUiMessage message;
  final String userAvatarUrl;

  @override
  Widget build(BuildContext context) {
    if (message.isFromUser) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 232),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message.text ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.28,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _UserAvatar(imageUrl: userAvatarUrl),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const _BotAvatar(),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.hasText)
                Container(
                  constraints: const BoxConstraints(maxWidth: 246),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: message.isLocationResponse
                        ? const Color(0xFFE9F5EB)
                        : const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: message.isError
                          ? const Color(0xFFF1C5C5)
                          : const Color(0xFFE3E8EA),
                    ),
                  ),
                  child: Text(
                    message.text ?? '',
                    style: TextStyle(
                      color: message.isError
                          ? const Color(0xFFB94545)
                          : AppColors.textBlack,
                      fontSize: 11.8,
                      height: 1.28,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              if (message.hasRestaurants)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: List<Widget>.generate(
                      message.restaurants.length,
                      (index) {
                        final restaurant = message.restaurants[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == message.restaurants.length - 1
                                ? 0
                                : 7,
                          ),
                          child: RestaurantRecommendationCard(
                            restaurant: restaurant,
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BotAvatar extends StatelessWidget {
  const _BotAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE6E6E6)),
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: Image.asset(
        AppImages.ai,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.trim().isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Image.asset(
                  AppImages.defaultProfileImage,
                  fit: BoxFit.cover,
                );
              },
            )
          : Image.asset(AppImages.defaultProfileImage, fit: BoxFit.cover),
    );
  }
}
