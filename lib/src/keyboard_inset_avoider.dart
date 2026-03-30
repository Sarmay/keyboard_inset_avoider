import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class KeyboardInsetAvoider extends ChangeNotifier {
  KeyboardInsetAvoider._();

  static const EventChannel _channel = EventChannel(
    'keyboard_inset_avoider/keyboard_insets',
  );

  static final KeyboardInsetAvoider instance = KeyboardInsetAvoider._();

  StreamSubscription<dynamic>? _subscription;
  bool _initialized = false;
  double _nativeInset = 0;

  double get nativeInset => _nativeInset;

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

  double effectiveInsetOf(BuildContext context) {
    ensureInitialized();
    return math.max(MediaQuery.viewInsetsOf(context).bottom, _nativeInset);
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
