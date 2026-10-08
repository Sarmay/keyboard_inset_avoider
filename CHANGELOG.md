## 0.2.0

* **Restructured**: the core (`KeyboardInsetAvoider`) now only measures and
  reports insets; it no longer knows about layout.
* **New** `KeyboardInsetPadding`: layout-agnostic `AnimatedPadding` that
  tracks the effective keyboard inset. Works the same inside dialogs, bottom
  sheets, stacks and scrollables.
* **New route/focus isolation**: `KeyboardInsetAvoider.isCurrentRoute` and
  `effectiveInsetForCurrentRoute` tell you whether an inset belongs to the
  current (top) route. `KeyboardInsetBuilder`, `KeyboardInsetPadding` and
  `KeyboardAvoidingLayout` now default to reacting only when they are the
  current route — so a dialog opening over a page no longer makes the page
  behind it jump.
  * Breaking change: `KeyboardInsetBuilder` gained an `onlyWhenCurrentRoute`
    parameter (defaults to `true`); previously it always reported the raw
    inset.
- `KeyboardAvoidingLayout` is now a thin composition over the new components
  and additionally accepts `onlyWhenCurrentRoute`.

## 0.1.0

* Initial release of `keyboard_inset_avoider`.
* Added Android native keyboard inset fallback for devices that report incorrect Flutter `viewInsets`.
* Added `KeyboardAvoidingLayout` and `KeyboardInsetBuilder` to simplify bottom input bar avoidance.
