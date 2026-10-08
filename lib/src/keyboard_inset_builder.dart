import 'package:flutter/widgets.dart';

import 'keyboard_inset_avoider.dart';

/// Signature for a builder that receives the effective keyboard inset.
typedef KeyboardInsetWidgetBuilder =
    Widget Function(BuildContext context, double keyboardInset);

/// Gives you the effective keyboard inset for the surrounding context.
///
/// This is the lightweight, layout-agnostic access point: use it when you
/// want to react to the inset yourself (a `Transform`, a custom `Stack`,
/// a scroll offset, …) without committing to the full layout in
/// `KeyboardAvoidingLayout`.
///
/// By default the inset is only reported while [KeyboardInsetAvoider
/// isCurrentRoute] is true, so an overlay (like a dialog) that opens above
/// the page does not make the underlying page jump. Pass
/// `onlyWhenCurrentRoute: false` to always receive the raw inset.
class KeyboardInsetBuilder extends StatelessWidget {
  const KeyboardInsetBuilder({
    super.key,
    required this.builder,
    this.onlyWhenCurrentRoute = true,
  });

  /// Builds a subtree that depends on [effectiveInsetForCurrentRoute].
  final KeyboardInsetWidgetBuilder builder;

  /// When `true` (default), [builder] receives `0.0` while this widget is
  /// not under the current route.
  final bool onlyWhenCurrentRoute;

  @override
  Widget build(BuildContext context) {
    final avoider = KeyboardInsetAvoider.instance..ensureInitialized();

    return AnimatedBuilder(
      animation: avoider,
      builder: (context, _) {
        final inset = onlyWhenCurrentRoute
            ? avoider.effectiveInsetForCurrentRoute(context)
            : avoider.effectiveInsetOf(context);
        return builder(context, inset);
      },
    );
  }
}