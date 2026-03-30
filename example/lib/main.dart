import 'package:flutter/material.dart';
import 'package:keyboard_inset_avoider/keyboard_inset_avoider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('keyboard_inset_avoider example')),
        body: const SafeArea(child: ExamplePage()),
      ),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardAvoidingLayout(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Open the keyboard and the bottom bar will stay visible.'),
          SizedBox(height: 24),
          Text('This example uses the plugin without editing MainActivity.'),
          SizedBox(height: 600),
        ],
      ),
      bottomBar: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type here',
                    border: InputBorder.none,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () => _controller.clear(),
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
