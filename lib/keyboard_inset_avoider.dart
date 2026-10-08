/// keyboard_inset_avoider: Reliable keyboard inset fallback and avoidance.
///
/// ## Responsibilities
///
/// * [KeyboardInsetAvoider] — global source of the native IME height and the
///   route-aware helpers for deciding *if* it applies here.
/// * [KeyboardInsetBuilder] — layout-agnostic access to the inset.
/// * [KeyboardInsetPadding] — drop-in bottom padding that tracks the inset.
/// * [KeyboardAvoidingLayout] — convenience "body + bottom bar" layout that
///   composes the above.
library;

export 'src/keyboard_avoiding_layout.dart' hide KeyboardInsetWidgetBuilder;
export 'src/keyboard_inset_avoider.dart';
export 'src/keyboard_inset_builder.dart';
export 'src/keyboard_inset_padding.dart';