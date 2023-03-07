import 'package:flutter/material.dart';
import 'package:web_browser/web_browser.dart';

class BrowserScreen extends StatefulWidget {
  final String Url;
  const BrowserScreen({super.key, required this.Url});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState(Url);
}

class _BrowserScreenState extends State<BrowserScreen> {
  final String Url;
  _BrowserScreenState(this.Url);
  WebBrowserController? controller;
  @override
  Widget build(BuildContext context) {
    //HTTPS olmasına özellikle tercih edelim.
    return Scaffold(
      appBar: AppBar(title: const Text('Burulaş')),
      body: WebBrowser(
        initialUrl: Url,
        javascriptEnabled: true,
        interactionSettings: WebBrowserInteractionSettings(
            topBar: Container(),
            bottomBar:
                Container()), //Yukarıdaki adres barı kapatmak için kullandık
        onCreated: (controller) {
          //Diğer işlemler için controller nesnesini dışarıya alıyoruz.
          this.controller = controller;
        },
      ),
    );
  }
}
