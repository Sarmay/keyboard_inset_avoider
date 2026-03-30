import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'keyboard_inset_avoider.dart';

typedef KeyboardInsetWidgetBuilder =
    Widget Function(BuildContext context, double keyboardInset);

class KeyboardInsetBuilder extends StatelessWidget {
  const KeyboardInsetBuilder({super.key, required this.builder});

  final KeyboardInsetWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final avoider = KeyboardInsetAvoider.instance..ensureInitialized();

    return AnimatedBuilder(
      animation: avoider,
      builder: (context, _) =>
          builder(context, avoider.effectiveInsetOf(context)),
    );
  }
}

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
  });

  final Widget body;
  final Widget? bottomBar;
  final EdgeInsets bodyPadding;
  final double horizontalPadding;
  final double bottomSpacing;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool includeBottomSafeArea;

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
    final avoider = KeyboardInsetAvoider.instance..ensureInitialized();

    return AnimatedBuilder(
      animation: avoider,
      builder: (context, _) {
        final keyboardInset = avoider.effectiveInsetOf(context);
        final safeAreaBottom = widget.includeBottomSafeArea
            ? MediaQuery.viewPaddingOf(context).bottom
            : 0.0;
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
