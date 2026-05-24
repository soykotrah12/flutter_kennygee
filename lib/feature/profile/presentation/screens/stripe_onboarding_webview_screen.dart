import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../../core/theme/app_colors.dart';

class StripeOnboardingWebViewScreen extends StatefulWidget {
  const StripeOnboardingWebViewScreen({super.key, required this.onboardingUrl});

  final String onboardingUrl;

  @override
  State<StripeOnboardingWebViewScreen> createState() =>
      _StripeOnboardingWebViewScreenState();
}

class _StripeOnboardingWebViewScreenState
    extends State<StripeOnboardingWebViewScreen> {
  late final WebViewController _webViewController;
  bool _isPageLoading = true;
  bool _hasReturned = false;
  bool _hasLoadError = false;
  String _loadErrorMessage = '';

  @override
  void initState() {
    super.initState();

    PlatformWebViewControllerCreationParams controllerParams =
        const PlatformWebViewControllerCreationParams();
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      controllerParams =
          AndroidWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
            controllerParams,
          );
    }

    _webViewController =
        WebViewController.fromPlatformCreationParams(controllerParams)
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.transparent)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) {
                if (!mounted) return;
                setState(() {
                  _isPageLoading = true;
                  _hasLoadError = false;
                });
              },
              onPageFinished: (_) {
                if (!mounted) return;
                setState(() => _isPageLoading = false);
              },
              onNavigationRequest: (request) {
                if (_isCompletionUrl(request.url)) {
                  _closeAndReturn(result: true);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              onWebResourceError: (error) {
                if (!mounted) return;
                setState(() {
                  _isPageLoading = false;
                  _hasLoadError = true;
                  _loadErrorMessage = error.description.isNotEmpty
                      ? error.description
                      : 'Unable to load Stripe onboarding.';
                });
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.onboardingUrl));

    if (_webViewController.platform is AndroidWebViewController) {
      final AndroidWebViewController androidController =
          _webViewController.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }
  }

  bool _isCompletionUrl(String url) {
    final normalized = url.toLowerCase();
    return normalized.contains('return') ||
        normalized.contains('success') ||
        normalized.contains('stripe-connect');
  }

  void _closeAndReturn({required bool result}) {
    if (_hasReturned || !mounted) return;
    _hasReturned = true;
    Get.back<bool>(result: result);
  }

  Future<void> _retryLoading() async {
    setState(() {
      _hasLoadError = false;
      _isPageLoading = true;
      _loadErrorMessage = '';
    });
    await _webViewController.loadRequest(Uri.parse(widget.onboardingUrl));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _closeAndReturn(result: false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: const Text(
            'Stripe Onboarding',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => _closeAndReturn(result: false),
            icon: const Icon(Icons.close),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: WebViewWidget(
                      controller: _webViewController,
                      gestureRecognizers:
                          const <Factory<OneSequenceGestureRecognizer>>{
                            Factory<PanGestureRecognizer>(
                              PanGestureRecognizer.new,
                            ),
                            Factory<TapGestureRecognizer>(
                              TapGestureRecognizer.new,
                            ),
                          },
                    ),
                  ),
                  if (_isPageLoading && !_hasLoadError)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          color: AppColors.background(
                            context,
                          ).withValues(alpha: 0.26),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  if (_hasLoadError)
                    Positioned.fill(
                      child: Container(
                        color: AppColors.background(context),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 44,
                              color: AppColors.secondaryText(context),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Unable to load Stripe onboarding',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.primaryText(context),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _loadErrorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.secondaryText(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: 130,
                              child: ElevatedButton(
                                onPressed: _retryLoading,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
