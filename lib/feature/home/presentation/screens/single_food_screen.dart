import 'package:flutter/material.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/food_model.dart';

class SingleFoodScreen extends StatefulWidget {
  const SingleFoodScreen({required this.food, super.key});

  final FoodModel food;

  @override
  State<SingleFoodScreen> createState() => _SingleFoodScreenState();
}

class _SingleFoodScreenState extends State<SingleFoodScreen> {
  late final PageController _bannerController;
  late final List<String> _bannerImages;
  int _activeBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _bannerImages = <String>[
      widget.food.image,
      widget.food.image,
      widget.food.image,
      widget.food.image,
    ];
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 395,
                        width: double.infinity,
                        child: PageView.builder(
                          controller: _bannerController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _bannerImages.length,
                          onPageChanged: (int index) {
                            setState(() => _activeBannerIndex = index);
                          },
                          itemBuilder: (_, index) {
                            return Image.asset(
                              _bannerImages[index],
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 56,
                        left: 20,
                        child: _CircleActionButton(
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const Positioned(
                        top: 56,
                        right: 20,
                        child: _CircleActionButton(icon: Icons.favorite_border),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(
                            _bannerImages.length,
                            (int index) => Padding(
                              padding: EdgeInsets.only(
                                right: index == _bannerImages.length - 1
                                    ? 0
                                    : 8,
                              ),
                              child: _Dot(active: _activeBannerIndex == index),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -14),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.appBackground,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(26),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.food.name,
                                    style: const TextStyle(
                                      color: AppColors.textBlack,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      height: 1.05,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$${widget.food.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppColors.primaryOrange,
                                  size: 18,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  widget.food.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${widget.food.reviewsCount} Reviews)',
                                  style: const TextStyle(
                                    color: AppColors.textBlack,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Description',
                              style: TextStyle(
                                color: AppColors.textBlack,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.food.description,
                              style: const TextStyle(
                                color: Color(0xFF6E6E6E),
                                fontSize: 14,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                16,
                                14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          widget.food.image,
                                          width: 84,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.food.restaurantName,
                                              style: const TextStyle(
                                                color: AppColors.textBlack,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.food.distance,
                                              style: const TextStyle(
                                                color: AppColors.primaryGreen,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: const BoxDecoration(
                                          color: AppColors.appBackground,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            AppImages.map,
                                            width: 24,
                                            height: 24,
                                          ),
                                        )
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: Color(0xFF777777),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          widget.food.address,
                                          style: const TextStyle(
                                            color: Color(0xFF6E6E6E),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Color(0xFF777777),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Open - ${widget.food.openingHours}',
                                          style: const TextStyle(
                                            color: Color(0xFF6E6E6E),
                                            fontSize: 12,
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: _BottomActionButton(
                    icon: Icons.turn_right,
                    label: 'Directions',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _BottomActionButton(
                    icon: Icons.bookmark_border,
                    label: 'Save',
                    onTap: () {},
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

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFF4F6077).withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 10 : 10,
      height: active ? 10 : 10,
      decoration: BoxDecoration(
        color: active ? Colors.white : const Color(0xFF7B7E84),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(34),
          ),
          elevation: 0,
        ),
        icon: Icon(icon, color: Colors.white, size: 32),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}
