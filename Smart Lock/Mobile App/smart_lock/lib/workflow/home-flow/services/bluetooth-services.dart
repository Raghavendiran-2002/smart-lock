import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Bluetooth_Devices_Connected extends StatefulWidget {
  const Bluetooth_Devices_Connected({Key? key}) : super(key: key);

  @override
  State<Bluetooth_Devices_Connected> createState() =>
      _Bluetooth_Devices_ConnectedState();
}

class _Bluetooth_Devices_ConnectedState
    extends State<Bluetooth_Devices_Connected> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  void ScanDevices() {
    FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 1));
  }

  void connectBLEDevice(BluetoothDevice device) async {
    print("connecting");
    await device.connect(autoConnect: false);
    print("connected");
    DiscoverSerives(device);
  }

  void DiscoverSerives(d) async {
    List<BluetoothService> services = await d.discoverServices();
    print(services[0].uuid.toString());
    if (services[0].uuid.toString() == "28406d0e-73e1-11ed-a1eb-0242ac120002") {
      List<BluetoothCharacteristic> characteristics =
          services[0].characteristics;
      if (characteristics[0].uuid.toString() ==
          "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
        await characteristics[0].write("hello".codeUnits);
        List<int> value = await characteristics[0].read();
        print(value);
      }
    }
  }

  void DiscoverDevice() async {
    var s = await flutterBlue.connectedDevices;
    if (s.length != 0) {
      if (s[0].name.toString() == "MyESP32") {
        DiscoverSerives(s[0]);
      }
    } else {
      flutterBlue.startScan(timeout: Duration(seconds: 1));
      bool isFirst = true;
      flutterBlue.scanResults.listen((results) {
        for (ScanResult r in results) {
          print('${r.device.name} found : ${r.device.id}');
          if (r.device.id.toString() ==
                  "9BA0DA5B-3DE5-BFFE-7879-CFCBA5F5D2B5" &&
              isFirst) {
            connectBLEDevice(r.device);
            isFirst = false;
          }
        }
      });
      flutterBlue.stopScan();
    }
  }

  @override
  void initState() {
    DiscoverDevice();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Row(
          children: [
            Center(child: Text("Hi")),
          ],
        ),
      ),
    );
  }
}
