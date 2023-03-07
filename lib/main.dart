import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nativebridgetest/screens/MainScreen.dart';
import 'package:nativebridgetest/screens/NativeScreen.dart';
import 'package:nativebridgetest/screens/PrinterScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Bridge Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: EasyLoading.init(),
      initialRoute: '/Printer',
      routes: {
        '/': ((context) => const MainScreen()),
        '/NativeTest': ((context) => const NativeScreen()),
        '/Printer': ((context) => const PrinterScreen())
      },
    );
  }
}
