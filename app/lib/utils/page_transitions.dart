import 'package:flutter/material.dart';

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Offset beginOffset;
  final Offset endOffset;
  final Duration duration;

  SlidePageRoute({
    required this.page,
    this.beginOffset = const Offset(1.0, 0.0),
    this.endOffset = Offset.zero,
    this.duration = const Duration(milliseconds: 300),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var slideAnimation = Tween<Offset>(
              begin: beginOffset,
              end: endOffset,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ));

            var fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ));

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  ScalePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var scaleAnimation = Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ));

            var fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ));

            return ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

class CustomPageTransitions {
  static Route<T> slideFromRight<T>(Widget page, {RouteSettings? settings}) {
    return SlidePageRoute<T>(
      page: page,
      beginOffset: const Offset(1.0, 0.0),
      settings: settings,
    );
  }

  static Route<T> slideFromLeft<T>(Widget page, {RouteSettings? settings}) {
    return SlidePageRoute<T>(
      page: page,
      beginOffset: const Offset(-1.0, 0.0),
      settings: settings,
    );
  }

  static Route<T> slideFromBottom<T>(Widget page, {RouteSettings? settings}) {
    return SlidePageRoute<T>(
      page: page,
      beginOffset: const Offset(0.0, 1.0),
      settings: settings,
    );
  }

  static Route<T> slideFromTop<T>(Widget page, {RouteSettings? settings}) {
    return SlidePageRoute<T>(
      page: page,
      beginOffset: const Offset(0.0, -1.0),
      settings: settings,
    );
  }

  static Route<T> scale<T>(Widget page, {RouteSettings? settings}) {
    return ScalePageRoute<T>(
      page: page,
      settings: settings,
    );
  }

  static Route<T> fade<T>(Widget page, {RouteSettings? settings}) {
    return FadePageRoute<T>(
      page: page,
      settings: settings,
    );
  }
}
