import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The single source of truth for keyboard insets.
///
/// Responsibilities:
///  1. Keep the *amount* of IME coverage ([nativeInset] / [effectiveInsetOf])
///     — a physical fact about the screen, not about any route.
///  2. Help consumers decide whether an inset actually belongs to their
///     route ([isCurrentRoute], [effectiveInsetForCurrentRoute]).
///
/// It intentionally knows nothing about layout: applying the inset (padding,
/// transform, scroll offset…) is up to the lightweight widgets in
/// `keyboard_inset_builder.dart` and `keyboard_inset_padding.dart`, or to
/// your own custom handling.
class KeyboardInsetAvoider extends ChangeNotifier {
  KeyboardInsetAvoider._();

  static const EventChannel _channel = EventChannel(
    'keyboard_inset_avoider/keyboard_insets',
  );

  static final KeyboardInsetAvoider instance = KeyboardInsetAvoider._();

  StreamSubscription<dynamic>? _subscription;
  bool _initialized = false;
  double _nativeInset = 0;

  /// IME height measured by the native side, in logical pixels.
  ///
  /// This is the global physical fact: whenever the IME is up, this is its
  /// height regardless of which route is focused. Consumers that care about
  /// focus should use [effectiveInsetForCurrentRoute] instead.
  double get nativeInset => _nativeInset;

  /// Start listening to the native channel.
  ///
  /// Safe to call from `build`; the subscription is created once and shared.
  void ensureInitialized() {
    if (_initialized) {
      return;
    }

    _initialized = true;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    _subscription = _channel.receiveBroadcastStream().listen(
      _handleNativeInset,
      onError: (_) => _setNativeInset(0),
    );
  }

  /// The inset that applies to [context] right now, regardless of the route:
  /// `max(MediaQuery.viewInsets.bottom, nativeInset)`.
  double effectiveInsetOf(BuildContext context) {
    ensureInitialized();
    return math.max(MediaQuery.viewInsetsOf(context).bottom, _nativeInset);
  }

  /// Like [effectiveInsetOf], but returns `0.0` when [context] does not
  /// belong to the current route — i.e. when the keyboard actually belongs to
  /// an overlay (dialog, modal…) on top.
  double effectiveInsetForCurrentRoute(BuildContext context) {
    if (!isCurrentRoute(context)) {
      return 0.0;
    }
    return effectiveInsetOf(context);
  }

  /// Whether [context] resides in the top-most route.
  ///
  /// When an overlay/dialog is open (and owns the keyboard), routes below it
  /// are still mounted and would otherwise react to the same global inset —
  /// this is the guard that prevents "background input bar jumps while a
  /// dialog is open".
  ///
  /// Returns `true` when there is no `ModalRoute` (plain widget tests, or a
  /// widget that intentionally manages its own visibility).
  static bool isCurrentRoute(BuildContext context) {
    return ModalRoute.of(context)?.isCurrent ?? true;
  }

  void _handleNativeInset(dynamic value) {
    final nextInset = value is num ? value.toDouble() : 0.0;
    _setNativeInset(nextInset);
  }

  void _setNativeInset(double value) {
    if (value == _nativeInset) {
      return;
    }

    _nativeInset = value;
    notifyListeners();
  }

  @visibleForTesting
  void debugSetNativeInset(double value) {
    _initialized = true;
    _setNativeInset(value);
  }

  @visibleForTesting
  Future<void> debugReset() async {
    await _subscription?.cancel();
    _subscription = null;
    _initialized = false;
    final previousInset = _nativeInset;
    _nativeInset = 0;
    if (previousInset != 0) {
      notifyListeners();
    }
  }
}