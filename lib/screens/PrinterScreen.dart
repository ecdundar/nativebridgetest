import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  //Channel ismi native tarafla aynı olmalı
  static const platformMethod = MethodChannel("flutter.burulas/battery");
  bool isBluetoothAvailable = false;

  void checkBluetooth() async {
    try {
      final bool result = await platformMethod.invokeMethod("checkBluetooth");
      isBluetoothAvailable = result;
    } on PlatformException catch (e) {
      isBluetoothAvailable = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Bluetooth Printer')),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    checkBluetooth();
                  },
                  child: const Text('Bluetooth Destekliyor Mu?')),
            ],
          ),
        ));
  }
}
