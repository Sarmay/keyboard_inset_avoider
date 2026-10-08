import 'package:flutter/widgets.dart';

import 'keyboard_inset_avoider.dart';

/// Adds the effective keyboard inset as bottom padding around [child].
///
/// This is the drop-in, layout-agnostic way to keep content above the IME:
/// it only changes bottom padding, so it composes with any layout
/// (`Column`, `Stack`, `Padding`, scrollables…) and works identically inside
/// dialogs and bottom sheets.
///
/// The padding animates on inset changes (default 220ms) and, by default,
/// is only applied while this widget is under the current route so overlays
/// don't move the page behind them. Set `onlyWhenCurrentRoute: false` to
/// always apply the raw inset.
class KeyboardInsetPadding extends StatelessWidget {
  const KeyboardInsetPadding({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOut,
    this.bottomSpacing = 0.0,
    this.onlyWhenCurrentRoute = true,
  });

  /// The subtree that should sit above the keyboard.
  final Widget child;

  /// Animation duration for inset changes.
  final Duration duration;

  /// Animation curve for inset changes.
  final Curve curve;

  /// Extra bottom padding on top of the keyboard inset.
  final double bottomSpacing;

  /// If `true` (default), the padding collapses to `0` while the widget is
  /// not under the current route (e.g. below a dialog).
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
        return AnimatedPadding(
          duration: duration,
          curve: curve,
          padding: EdgeInsets.only(bottom: inset + bottomSpacing),
          child: child,
        );
      },
    );
  }
}