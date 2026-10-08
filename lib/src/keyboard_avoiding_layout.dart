import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'keyboard_inset_builder.dart';

/// Kept for API compatibility so existing call sites keep compiling.
///
/// New code should prefer the lighter [KeyboardInsetBuilder] /
/// `KeyboardInsetPadding` components; this typedef only exists so that
/// `typedef KeyboardAvoidingLayout` users that imported the builder from
/// this library still work.
@Deprecated(
  'Import KeyboardInsetWidgetBuilder from keyboard_inset_builder.dart.',
)
typedef KeyboardInsetWidgetBuilder =
    Widget Function(BuildContext context, double keyboardInset);

/// A convenience layout for the classic "scrollable body + anchored bottom
/// input bar" shape.
///
/// This is now a thin composition over [KeyboardInsetBuilder]: the body gets
/// bottom padding, the bottom bar is lifted by the effective inset, and by
/// default the whole thing only reacts while it is under the current route
/// (so a dialog on top won't move the page underneath it).
///
/// For shapes that are not "body + bottom bar" — dialogs, sheets, custom
/// stacks — prefer [KeyboardInsetPadding] or [KeyboardInsetBuilder], which
/// are layout-agnostic.
class KeyboardAvoidingLayout extends StatefulWidget {
  const KeyboardAvoidingLayout({
    super.key,
    required this.body,
    this.bottomBar,
    this.bodyPadding = EdgeInsets.zero,
    this.horizontalPadding = 16,
    this.bottomSpacing = 12,
    this.animationDuration = const Duration(milliseconds: 220),
    this.animationCurve = Curves.easeOut,
    this.includeBottomSafeArea = false,
    this.onlyWhenCurrentRoute = true,
  });

  final Widget body;
  final Widget? bottomBar;
  final EdgeInsets bodyPadding;
  final double horizontalPadding;
  final double bottomSpacing;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool includeBottomSafeArea;

  /// When `true` (default), the layout stops reacting to the keyboard while
  /// it is not the current route — preventing the page behind a dialog from
  /// jumping when that dialog owns the keyboard.
  final bool onlyWhenCurrentRoute;

  @override
  State<KeyboardAvoidingLayout> createState() => _KeyboardAvoidingLayoutState();
}

class _KeyboardAvoidingLayoutState extends State<KeyboardAvoidingLayout> {
  double _bottomBarHeight = 0;

  void _handleBottomBarSizeChanged(Size size) {
    if (_bottomBarHeight == size.height) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _bottomBarHeight == size.height) {
        return;
      }
      setState(() {
        _bottomBarHeight = size.height;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = widget.includeBottomSafeArea
        ? MediaQuery.viewPaddingOf(context).bottom
        : 0.0;

    return KeyboardInsetBuilder(
      onlyWhenCurrentRoute: widget.onlyWhenCurrentRoute,
      builder: (context, keyboardInset) {
        final bottomOffset =
            (keyboardInset > 0 ? keyboardInset : safeAreaBottom) +
            widget.bottomSpacing;
        final bodyBottomPadding = widget.bottomBar == null
            ? 0.0
            : _bottomBarHeight + bottomOffset;

        return Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: widget.bodyPadding.add(
                  EdgeInsets.only(bottom: bodyBottomPadding),
                ),
                child: widget.body,
              ),
            ),
            if (widget.bottomBar != null)
              AnimatedPositioned(
                duration: widget.animationDuration,
                curve: widget.animationCurve,
                left: widget.horizontalPadding,
                right: widget.horizontalPadding,
                bottom: bottomOffset,
                child: _MeasureSize(
                  onSizeChanged: _handleBottomBarSizeChanged,
                  child: widget.bottomBar!,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onSizeChanged, required super.child});

  final ValueChanged<Size> onSizeChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMeasureSize(onSizeChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMeasureSize renderObject,
  ) {
    renderObject.onSizeChanged = onSizeChanged;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onSizeChanged);

  ValueChanged<Size> onSizeChanged;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();

    final newSize = child?.size;
    if (newSize == null || newSize == _oldSize) {
      return;
    }

    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onSizeChanged(newSize);
    });
  }
}