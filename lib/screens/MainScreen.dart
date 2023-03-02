import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native Bridge Test')),
      body: Container(
        color: Colors.yellow,
        child: Center(
            child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Browser Aç'))),
      ),
    );
  }
}
