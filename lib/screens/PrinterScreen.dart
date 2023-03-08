import 'dart:async';

import 'package:flutter/cupertino.dart';
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
  //MethodChannel metod void çağırmak için kullanılıyor, event channel asenkron event çağrısı için kullanılyıor.
  static const platformMethod = MethodChannel("flutter.burulas/battery");
  static const platformEvent = EventChannel("flutter.burulas/eventChannel");
  static const platformEvent2 = EventChannel("flutter.burulas/eventChannel2");
  static const bluetoothDiscoveryEvent =
      EventChannel("flutter.burulas/eventBluetoothDiscovery");

  bool isBluetoothAvailable = false;
  bool isBluetoothOpen = false;

  late StreamSubscription _streamSubscription;
  late StreamSubscription _streamSubscriptionBluetoothDiscovery;
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
    //startListener();
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

  String lastPrinterName = "";
  List<String> _ListPrinters = List.empty(growable: true);
  void printLabelWithSelection(BuildContext context) async {
    EasyLoading.show(status: "Cihazlar taranıyor");
    _ListPrinters.clear();
    _streamSubscriptionBluetoothDiscovery =
        bluetoothDiscoveryEvent.receiveBroadcastStream().listen((value) {
      if (value == "###FINISHED###") {
        EasyLoading.dismiss();
        _streamSubscriptionBluetoothDiscovery.cancel();
        if (_ListPrinters.isEmpty) {
          EasyLoading.showError("Bluetooth yazıcı bulunamadı");
        } else if (_ListPrinters.length == 1) {
          connectToPrinter(_ListPrinters.first);
        } else {
          showPrinterActionSheet(context);
        }
      } else {
        _ListPrinters.add(value);
        lastPrinterName = value;
        print(value);
      }
    });
  }

  void showPrinterActionSheet(BuildContext ctx) {
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => CupertinoActionSheet(
              message: Center(
                child: Container(
                    width: 100,
                    height: 50,
                    child: const Text('Yazıcı Seçiniz')),
              ),
              actions: _ListPrinters.map(
                (e) => CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      connectToPrinter(e);
                    },
                    child: Text(e)),
              ).toList(),
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'Vazgeç',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ));
  }

  void connectToPrinter(String printerNameAndAdress) async {
    // ignore: prefer_interpolation_to_compose_strings
    var metin = "! 0 200 200 321 1\r\n" +
        "PW 384\r\n" +
        "TONE 0\r\n" +
        "SPEED 3\r\n" +
        "ON-FEED IGNORE\r\n" +
        "NO-PACE\r\n" +
        "BAR-SENSE\r\n" +
        "BT 0 0 3\r\n" +
        "B EAN13 0 20 50 149 42 1234567890128\r\n" +
        "T 4 0 84 138 BURULAS\r\n" +
        "T 4 0 110 206 EGITIM\r\n" +
        "PRINT\r\n";
    final bool result = await platformMethod.invokeMethod("connectToPrinter",
        {"printerNameAndAdress": printerNameAndAdress, "metin": metin});
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        printLabelWithSelection(context);
                      },
                      child: const Text('Barkod Seçimli Yazdır')),
                  const SizedBox(height: 20),
                  Text(lastPrinterName.toString()),
                ],
              ),
            )));
  }
}
