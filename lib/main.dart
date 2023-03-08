import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:json_theme/json_theme.dart';
import 'package:nativebridgetest/screens/MainScreen.dart';
import 'package:nativebridgetest/screens/NativeScreen.dart';
import 'package:nativebridgetest/screens/PrinterScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeStr =
      await rootBundle.loadString('lib/assets/appainter_theme.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

  runApp(MyApp(theme: theme));
}

class MyApp extends StatelessWidget {
  final ThemeData theme;
  const MyApp({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Bridge Test',
      theme: theme,
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
