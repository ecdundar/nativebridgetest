import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  //Channel ismi native tarafla aynı olmalı
  static const platformMethod = MethodChannel("flutter.burulas/battery");
  bool isBluetoothAvailable = false;
  bool isBluetoothOpen = false;

  void checkBluetooth() async {
    try {
      final bool result = await platformMethod.invokeMethod("checkBluetooth");
      isBluetoothAvailable = result;

      if (isBluetoothAvailable) {
        EasyLoading.showSuccess("Bluetooth destekleniyor");
      } else {
        EasyLoading.showError("Bluetooth desteklenmiyor");
      }
    } on PlatformException catch (e) {
      isBluetoothAvailable = false;
    }
    setState(() {});
  }

  void getBluetoothIsOpen() async {
    try {
      final bool result =
          await platformMethod.invokeMethod("getBluetoothIsOpen");
      isBluetoothOpen = result;

      if (isBluetoothOpen) {
        EasyLoading.showSuccess("Bluetooth AÇIK");
      } else {
        EasyLoading.showError("Bluetooth KAPALI");
      }
    } on PlatformException catch (e) {
      isBluetoothAvailable = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Bluetooth Printer')),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        checkBluetooth();
                      },
                      child: const Text('Bluetooth Destekliyor Mu?')),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        getBluetoothIsOpen();
                      },
                      child: const Text('Bluetooth Açık Mı?')),
                ],
              ),
            )));
  }
}
