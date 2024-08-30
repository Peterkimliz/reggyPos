import 'dart:async';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'
    as bluetooth;
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reggypos/controllers/printercontroller.dart';
import 'package:reggypos/utils/colors.dart';
import 'package:reggypos/widgets/minor_title.dart';

class PrintingPage extends StatefulWidget {
  const PrintingPage({Key? key}) : super(key: key);

  @override
  PrintingPageState createState() => PrintingPageState();
}

class PrintingPageState extends State<PrintingPage> {
  PrinterController printerController = Get.find<PrinterController>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> requestBlueToothPermission() async {
    bluetooth.BluetoothState bluetoothState =
        await bluetooth.FlutterBluetoothSerial.instance.state;
    var status = await Permission.bluetoothConnect.status;
    if (!status.isGranted) {
      await Permission.bluetoothConnect.request();
    }
    if (bluetoothState == bluetooth.BluetoothState.STATE_OFF) {
      bool? enable =
          await bluetooth.FlutterBluetoothSerial.instance.requestEnable();
      if (enable == true) {
        initBluetooth();
      }
    } else {
      initBluetooth();
    }
  }

  Future<void> initBluetooth() async {
    try {
      printerController.searchingPrinters.value = true;
      printerController.bluetoothPrint
          .startScan(timeout: const Duration(seconds: 4));
      bool isConnected =
          await printerController.bluetoothPrint.isConnected ?? false;
      printerController.bluetoothPrint.state.listen((state) {
        switch (state) {
          case BluetoothPrint.CONNECTED:
            printerController.connected.value = true;
            printerController.tips.value = 'connect success';
            break;
          case BluetoothPrint.DISCONNECTED:
            printerController.connected.value = false;
            printerController.tips.value = 'disconnect success';
            break;
          default:
            break;
        }
      });
      printerController.searchingPrinters.value = false;
      if (!mounted) return;
      if (isConnected) {
        printerController.connected.value = true;
      }
    } catch (e) {
      printerController.searchingPrinters.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text('Select Printer'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 5),
            Obx(() => Center(
                  child: InkWell(
                    onTap: () async {
                      requestBlueToothPermission();
                    },
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(width: 1, color: AppColors.mainColor),
                      ),
                      child: printerController.searchingPrinters.value
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.print,
                                  color: AppColors.mainColor,
                                ),
                                const SizedBox(width: 5),
                                minorTitle(
                                    title: "Scan for printers",
                                    color: AppColors.mainColor)
                              ],
                            ),
                    ),
                  ),
                )),
            const SizedBox(height: 10),
            StreamBuilder<List<BluetoothDevice>>(
                stream: printerController.bluetoothPrint.scanResults,
                initialData: const [],
                builder: (c, snapshot) {
                  return snapshot.data!.isEmpty
                      ? const Center(
                          child: Text("No printers detected"),
                        )
                      : Column(
                          children: snapshot.data!
                              .map((d) => ListTile(
                                    title: Text(d.name ?? ''),
                                    subtitle: Text(d.address ?? ''),
                                    onTap: () async {},
                                    trailing: Obx(() {
                                      return printerController.device?.value !=
                                                  null &&
                                              printerController
                                                      .device!.value!.address ==
                                                  d.address
                                          ? printersButton(
                                              title: "Disconnect",
                                              onTap: () async {
                                                printerController
                                                    .device?.value = null;
                                                printerController
                                                    .connected.value = false;
                                                printerController.tips.value =
                                                    'disconnecting...';
                                                await printerController
                                                    .bluetoothPrint
                                                    .disconnect();
                                              })
                                          : printersButton(
                                              title: "Connect",
                                              onTap: () async {
                                                printerController
                                                    .device?.value = d;
                                                if (printerController
                                                            .device?.value !=
                                                        null &&
                                                    printerController.device
                                                            ?.value!.address !=
                                                        null) {
                                                  printerController.tips.value =
                                                      'connecting...';

                                                  await printerController
                                                      .bluetoothPrint
                                                      .connect(printerController
                                                          .device!.value!);
                                                } else {
                                                  printerController.tips.value =
                                                      'please select device';
                                                }
                                              });
                                    }),
                                  ))
                              .toList(),
                        );
                }),
          ],
        ),
      ),
    );
  }

  Widget printersButton({required title, required VoidCallback onTap}) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        width: 100,
        height: 40,
        decoration: BoxDecoration(
            color: AppColors.mainColor,
            borderRadius: BorderRadius.circular(15)),
        child: Center(
          child: minorTitle(title: title, color: Colors.white),
        ),
      ),
    );
  }
}
