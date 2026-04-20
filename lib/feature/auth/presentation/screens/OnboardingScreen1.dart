import 'package:flutter/material.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_flow_controller.dart';

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({super.key, this.role});

  final AppUserRole? role;

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AuthFlowController _authFlowController;

  @override
  void initState() {
    super.initState();
    _authFlowController = ensureAuthFlowController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<_OnboardingData> get _slides {
    if (widget.role?.isOwner ?? false) {
      return const [
        _OnboardingData(
          titleTop: 'Discover Great',
          titleHighlight: 'Food',
          titleBottomRest: 'Near You',
          description:
              'Explore local restaurants tailored to your taste. Save your favorites, check ratings, and let AI guide you to the perfect spot for any occasion.',
          image: AppImages.ownerOnboarding1,
          footerArtwork: AppImages.onboardingFooterUser1,
        ),
        _OnboardingData(
          titleTop: 'Put Your',
          titleHighlight: 'Shop',
          titleBottomRest: 'on the Map',
          description:
              'Add your restaurant and menu items to reach nearby food lovers. Promote your business with top placement and grow your customer base effortlessly.',
          image: AppImages.ownerOnboarding2,
          footerArtwork: AppImages.onboardingFooterUser2,
        ),
        _OnboardingData(
          titleTop: 'Enjoy Food,',
          titleHighlight: 'Share',
          titleBottomRest: 'Moments',
          description:
              'Whether it\'s a date, family dinner, or casual outing, our AI helps you find the perfect place to make every meal memorable.',
          image: AppImages.ownerOnboarding3,
        ),
      ];
    }

    return const [
      _OnboardingData(
        titleTop: 'Discover Great',
        titleHighlight: 'Food',
        titleBottomRest: 'Near You',
        description:
            'Explore local restaurants tailored to your taste. Save your favorites, check ratings, and let AI guide you to the perfect spot for any occasion.',
        image: AppImages.userOnboarding1,
        footerArtwork: AppImages.onboardingFooterUser1,
      ),
      _OnboardingData(
        titleTop: 'Put Your',
        titleHighlight: 'Shop',
        titleBottomRest: 'on the Map',
        description:
            'Add your restaurant and menu items to reach nearby food lovers. Promote your business with top placement and grow your customer base effortlessly.',
        image: AppImages.userOnboarding2,
        footerArtwork: AppImages.onboardingFooterUser2,
      ),
      _OnboardingData(
        titleTop: 'Enjoy Food,',
        titleHighlight: 'Share',
        titleBottomRest: 'Moments',
        description:
            'Whether it\'s a date, family dinner, or casual outing, our AI helps you find the perfect place to make every meal memorable.',
        image: AppImages.userOnboarding3,
      ),
    ];
  }

  bool get _isLastPage => _currentPage == _slides.length - 1;
  bool get _hasPreviousPage => _currentPage > 0;

  void _next() {
    if (_isLastPage) {
      _authFlowController.finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _skip() {
    _authFlowController.finishOnboarding();
  }

  void _previous() {
    if (!_hasPreviousPage) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];

    return AppScaffold(
      useSafeArea: false,
      bodyPadding: EdgeInsets.zero,
      backgroundColor: AppColors.appBackground,
      body: Column(
        children: [
          Expanded(
            flex: 46,
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: _slides.length,
              onPageChanged: (value) => setState(() => _currentPage = value),
              itemBuilder: (context, index) {
                return SafeArea(
                  bottom: false,
                  child: Image.asset(
                    _slides[index].image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 54,
            child: Container(
              width: double.infinity,
              color: AppColors.appBackground,
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          slide.titleTop,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.08,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _DotsIndicator(
                        length: _slides.length,
                        current: _currentPage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: slide.titleHighlight,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: AppColors.primaryGreen,
                            height: 1,
                          ),
                        ),
                        TextSpan(
                          text: ' ${slide.titleBottomRest}',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: AppColors.textBlack,
                            height: 1.08,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    slide.description,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      color: AppColors.textGrey,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                  const Spacer(),
                  if (_isLastPage) ...[
                    
                    if (_hasPreviousPage) const SizedBox(height: 12),
                    PrimaryButton(
                      height: 51,
                      onPressed: _next,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _skip,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: AppColors.primaryGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 210,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: slide.footerArtwork == null
                                  ? const SizedBox.shrink()
                                  : Image.asset(
                                      slide.footerArtwork!,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _next,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.length, required this.current});

  final int length;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        length,
        (index) {
          final isSelected = index == current;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isSelected ? 12 : 8,
            height: isSelected ? 12 : 8,
            margin: EdgeInsets.only(left: index == 0 ? 0 : 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.primaryGreen
                  : const Color(0xFFD6D6D6),
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.titleTop,
    required this.titleHighlight,
    required this.titleBottomRest,
    required this.description,
    required this.image,
    this.footerArtwork,
  });

  final String titleTop;
  final String titleHighlight;
  final String titleBottomRest;
  final String description;
  final String image;
  final String? footerArtwork;
}
