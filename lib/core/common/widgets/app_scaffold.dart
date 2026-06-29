import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;

  final String? appBarTitle;
  final String? appBarSubtitle;
  final Widget? appBarSubtitleWidget;
  final PreferredSizeWidget? customAppBar;
  final double? titlespacing;
  final double toolbarHeight;

  /// AppBar actions
  final bool showActions;
  final List<Widget>? actions;

  /// Body behavior
  final bool useSafeArea;
  final bool isScrollable;

  final Widget? drawer;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry bodyPadding;
  final bool centerTitle;

  const AppScaffold({
    this.toolbarHeight = 72,
    super.key,
    required this.body,
    this.appBarTitle,
    this.appBarSubtitle,
    this.appBarSubtitleWidget,
    this.customAppBar,
    this.showActions = false,
    this.actions,
    this.useSafeArea = true,
    this.isScrollable = false,
    this.drawer,
    this.backgroundColor,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.titlespacing,
    this.bodyPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: bodyPadding,
      child: body,
    );

    /// Scroll control
    if (isScrollable) {
      content = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: content,
      );
    }

    /// SafeArea control
    if (useSafeArea) {
      content = SafeArea(
        top: false,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: drawer,
      appBar: customAppBar ??
          (appBarTitle != null ? _defaultAppBar(context, appBarTitle!) : null),
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

AppBar _defaultAppBar(BuildContext context, String title) {
  return AppBar(
    automaticallyImplyLeading: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    toolbarHeight: toolbarHeight,
    titleSpacing: titlespacing ?? 0,
    centerTitle: centerTitle,

    iconTheme: IconThemeData(
      color: AppColors.primaryText(context),
    ),

    title: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            height: 1.0,
          ),
        ),

        if (appBarSubtitleWidget != null) ...[
          const SizedBox(height: 4),
          DefaultTextStyle(
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
            child: appBarSubtitleWidget!,
          ),
        ] else if (appBarSubtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            appBarSubtitle!,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ],
    ),

    actions: showActions ? actions : null,
  );
}
}
