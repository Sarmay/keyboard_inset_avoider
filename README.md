# keyboard_inset_avoider

`keyboard_inset_avoider` provides a reliable Android keyboard inset fallback for devices where `MediaQuery.viewInsets.bottom` is incorrect, plus a small set of layout-agnostic helpers for keeping input above the IME.

## What It Solves

Some Android devices and custom ROMs show the keyboard but do not report a usable bottom inset back to Flutter. On those devices, input bars anchored to the bottom of the screen can be covered by the IME.

This plugin works around that by:

- reading Flutter's normal `MediaQuery.viewInsets.bottom`
- listening to Android window layout changes as a fallback
- exposing the larger of the two values as the **effective inset**
- letting each widget decide — based on its own route — whether that inset
  actually applies to it

## Design

The package is split so the layout is *optional*:

| Layer | Component | What it does |
|---|---|---|
| Data | `KeyboardInsetAvoider` | Single source of the IME height; knows nothing about layout. Provides `effectiveInsetOf(context)` plus `isCurrentRoute(context)` / `effectiveInsetForCurrentRoute(context)`. |
| Access | `KeyboardInsetBuilder` | Calls your builder with the effective inset. Apply it however you want (padding, transform, scroll offset…). |
| Drop-in | `KeyboardInsetPadding` | `AnimatedPadding` that tracks the inset. Works the same in pages, dialogs, and sheets. |
| Convenience | `KeyboardAvoidingLayout` | One-liner "body + anchored input bar" composition over the above. |

"Body + bottom bar" is only one shape; prefer `KeyboardInsetPadding` or
`KeyboardInsetBuilder` for anything else (dialogs, custom stacks, sheets).

### Route isolation — why overlays don't move the page behind them

The native inset is a screen-wide physical fact. When a dialog opens and its
input grabs focus, the keyboard's height is the same value the page underneath
would see. Without care, the page behind the dialog also lifts.

All three consuming widgets default to `onlyWhenCurrentRoute: true`, so they
only react while under the top-most (`ModalRoute.isCurrent`) route. If you
genuinely want to always react regardless of route, pass
`onlyWhenCurrentRoute: false`.

## Install

```yaml
dependencies:
  keyboard_inset_avoider:
    path: ../keyboard_inset_avoider
```

For a published package, replace the `path` dependency with the pub version.

## Usage

### Chat page with the convenience layout

```dart
import 'package:flutter/material.dart';
import 'package:keyboard_inset_avoider/keyboard_inset_avoider.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: KeyboardAvoidingLayout(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              Text('Messages...'),
            ],
          ),
          bottomBar: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(18),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: TextField(),
            ),
          ),
        ),
      ),
    );
  }
}
```

### Dialog that keeps its input above the IME

`DialogInsetsLift`-style manual wrappers are no longer needed — wrap the
dialog content with `KeyboardInsetPadding`:

```dart
showDialog<void>(
  context: context,
  builder: (context) => KeyboardInsetPadding(
    child: AlertDialog(
      content: const TextField(autofocus: true),
    ),
  ),
);
```

The page behind the dialog stays put because `onlyWhenCurrentRoute` defaults
to `true`.

### Custom layout with `KeyboardInsetBuilder`

```dart
KeyboardInsetBuilder(
  builder: (context, inset) => Transform.translate(
    offset: Offset(0, -inset),
    child: myWidget,
  ),
);
```

## Public API

- `KeyboardInsetAvoider.instance`
  - `nativeInset`
  - `effectiveInsetOf(context)`
  - `effectiveInsetForCurrentRoute(context)`
  - `static isCurrentRoute(context)`
- `KeyboardInsetBuilder`
- `KeyboardInsetPadding`
- `KeyboardAvoidingLayout`

## Notes

- No host `MainActivity` changes are required.
- Android gets the native fallback channel automatically through plugin registration.
- Non-Android platforms continue to use Flutter's own `MediaQuery.viewInsets.bottom`.