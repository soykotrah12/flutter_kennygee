import 'package:flutter/material.dart';

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

  const AppScaffold({
    this.toolbarHeight = 100,
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
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: toolbarHeight,
      titleSpacing: titlespacing ?? 4,

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ///  Title (Theme + override)
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w500, 
              height: 1.0,
              
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
            // maxLines: 2,
          ),

          ///  Subtitle (auto expand, no ellipsis)
          if (appBarSubtitleWidget != null) ...[
            const SizedBox(height: 4),
            DefaultTextStyle(
              style: textTheme.bodyMedium!.copyWith(
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
              // overflow: TextOverflow.visible,
              child: appBarSubtitleWidget!,
            ),
          ] else if (appBarSubtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              appBarSubtitle!,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ],
        ],
      ),

      actions: showActions ? actions : null,
    );
  }
}
