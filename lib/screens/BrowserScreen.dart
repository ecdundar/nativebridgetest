import 'package:flutter/material.dart';
import 'package:web_browser/web_browser.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  @override
  Widget build(BuildContext context) {
    //HTTPS olmasına özellikle tercih edelim.
    return Scaffold(
      appBar: AppBar(title: const Text('Burulaş')),
      body: const WebBrowser(
          initialUrl: 'https://www.burulas.com.tr', javascriptEnabled: true),
    );
  }
}
