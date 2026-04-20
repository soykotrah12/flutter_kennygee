import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class SystemNavBarHandler extends StatefulWidget {
  final Widget child;
  final Duration autoHideDuration;

  const SystemNavBarHandler({
    super.key,
    required this.child,
    this.autoHideDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<SystemNavBarHandler> createState() => _SystemNavBarHandlerState();
}

class _SystemNavBarHandlerState extends State<SystemNavBarHandler> {
  late Timer _hideTimer;
  bool _isNavBarVisible = false;

  @override
  void initState() {
    super.initState();
    _hideTimer = Timer(Duration.zero, () {});
    _hideSystemNavBar();
  }

  void _hideSystemNavBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
    _isNavBarVisible = false;
  }

  void _showSystemNavBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _isNavBarVisible = true;

    // Auto-hide after duration
    _hideTimer.cancel();
    _hideTimer = Timer(widget.autoHideDuration, () {
      if (mounted) {
        _hideSystemNavBar();
      }
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy < -10) {
      // Dragging upward
      if (!_isNavBarVisible) {
        _showSystemNavBar();
      }
    }
  }

  @override
  void dispose() {
    if (_hideTimer.isActive) {
      _hideTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _handleDragUpdate,
      child: widget.child,
    );
  }
}
