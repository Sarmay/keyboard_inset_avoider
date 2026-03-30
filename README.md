# keyboard_inset_avoider

`keyboard_inset_avoider` provides a reliable Android keyboard inset fallback for devices where `MediaQuery.viewInsets.bottom` is incorrect, plus a simple layout helper for bottom input bars.

## What It Solves

Some Android devices and custom ROMs show the keyboard but do not report a usable bottom inset back to Flutter. On those devices, input bars anchored to the bottom of the screen can be covered by the IME.

This plugin works around that by:

- reading Flutter's normal `MediaQuery.viewInsets.bottom`
- listening to Android window layout changes as a fallback
- exposing the larger of the two values to Flutter

## Install

```yaml
dependencies:
  keyboard_inset_avoider:
    path: ../keyboard_inset_avoider
```

For a published package, replace the `path` dependency with the pub version.

## Usage

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

## Public API

- `KeyboardInsetAvoider.instance.effectiveInsetOf(context)`
- `KeyboardInsetBuilder`
- `KeyboardAvoidingLayout`

## Notes

- No host `MainActivity` changes are required.
- Android gets the native fallback channel automatically through plugin registration.
- Non-Android platforms continue to use Flutter's own `MediaQuery.viewInsets.bottom`.
