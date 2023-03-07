import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeScreen extends StatefulWidget {
  const NativeScreen({super.key});

  @override
  State<NativeScreen> createState() => _NativeScreenState();
}

class _NativeScreenState extends State<NativeScreen> {
  //Channel ismi native tarafla aynı olmalı
  static const platformMethod = MethodChannel("flutter.burulas/battery");
  String _level = "---";

  void getBatteryLevel() async {
    String blevel = "";
    try {
      final int result = await platformMethod.invokeMethod("getBatteryLevel");
      blevel = result.toString();
    } on PlatformException catch (e) {
      blevel = "Pil durumu okunamadı";
    }
    setState(() {
      _level = blevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native Bridge Test')),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(_level),
        const SizedBox(height: 10),
        ElevatedButton(
            onPressed: () {
              getBatteryLevel();
            },
            child: const Text('Pil Seviyesini Getir'))
      ])),
    );
  }
}
