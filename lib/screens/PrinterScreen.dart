import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  //Channel ismi native tarafla aynı olmalı
  //Android 30 öncesi Bluetooth  erişimi için MainActivity.kt de yetki farklılıkları ile ilgili düzenleme yaptık.
  //Android 30 sonrası BLUETOOTH_SCAN, BLUETOOTH_CONNECT, öncesi BLUETOOTH ve BLUETOOTH_ADMIN yetkileri kullanıldı.
  //Android 29 sonrası bluetooth cihazlara erişimde Konum un hen açık hende uygulamanın konuma yetkili olması gerekiyor.
  static const platformMethod = MethodChannel("flutter.burulas/battery");
  static const platformEvent = EventChannel("flutter.burulas/eventChannel");
  static const platformEvent2 = EventChannel("flutter.burulas/eventChannel2");

  bool isBluetoothAvailable = false;
  bool isBluetoothOpen = false;

  late StreamSubscription _streamSubscription;
  double _currentValue = 0.0;

  //Start Listener ile Event Channel i başlatıyoruz
  void startListener() {
    _streamSubscription =
        platformEvent.receiveBroadcastStream().listen(listenStream);

    _streamSubscription.onDone(() {
      print('işlem bitti');
    });
  }

  //Event Channel Start listener sonucunu dinleyici fonksiyonumuz
  void listenStream(value) {
    setState(() {
      _currentValue = value;
    });
  }

  //Event Channel İptal Et
  void cancelStream() {
    print('cancelStream');
    _streamSubscription.cancel();
    setState(() {
      _currentValue = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    startListener();
  }

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

  void openBluetooth() async {
    try {
      if (await Permission.bluetooth.isGranted == false) {
        await Permission.bluetooth.request();
      }
      if (await Permission.bluetoothConnect.isGranted == false) {
        await Permission.bluetoothConnect.request();
      }
      final bool result = await platformMethod.invokeMethod("openBluetooth");
      if (result) {
        EasyLoading.showSuccess("Bluetooth AÇILDI");
        isBluetoothOpen = true;
      } else {
        EasyLoading.showError("Bluetooth status değişmedi");
      }
      setState(() {});
    } on PlatformException catch (e) {
      EasyLoading.showError(e.message ?? "");
    }
  }

  void closeBluetooth() async {
    try {
      final bool result = await platformMethod.invokeMethod("closeBluetooth");
      if (result) {
        EasyLoading.showSuccess("Bluetooth KAPATILDI");
        isBluetoothOpen = false;
      } else {
        EasyLoading.showError("Bluetooth status değişmedi");
      }
      setState(() {});
    } on PlatformException catch (e) {
      EasyLoading.showError(e.message ?? "");
    }
  }

  void printLabel() async {
    try {
      final bool result = await platformMethod.invokeMethod("printLabel");
      if (result) {
        EasyLoading.showSuccess("YAZDIRILDI");
      } else {
        EasyLoading.showError("Yazdırma işlemi gerçekleştirilemedi.");
      }
      setState(() {});
    } on PlatformException catch (e) {
      EasyLoading.showError(e.message ?? "");
    }
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                openBluetooth();
                              },
                              child: const Text('Bluetooth Aç'))),
                      const SizedBox(width: 20),
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                closeBluetooth();
                              },
                              child: const Text('Bluetooth Kapat'))),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () {
                        printLabel();
                      },
                      child: const Text('Barkod Yazdır')),
                  const SizedBox(height: 20),
                  Text(_currentValue.toString()),
                ],
              ),
            )));
  }
}
