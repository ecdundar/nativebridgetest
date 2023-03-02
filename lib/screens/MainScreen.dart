import 'package:flutter/material.dart';
import 'package:nativebridgetest/screens/BrowserScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void browserAc(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const BrowserScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native Bridge Test')),
      body: Container(
        color: Colors.yellow,
        child: Center(
            child: ElevatedButton.icon(
                onPressed: () {
                  browserAc(context);
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Browser Aç'))),
      ),
    );
  }
}
