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
    services.forEach((service) async {
      if (service.uuid.toString() == "28406d0e-73e1-11ed-a1eb-0242ac120002") {
        List<BluetoothCharacteristic> characteristics = service.characteristics;
        for (BluetoothCharacteristic characteristic in characteristics) {
          if (characteristic.uuid.toString() ==
              "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
            List<int> value = await characteristic.read();
            print(value);
            print("**********************************");
            await characteristic.write("hello".codeUnits);
          }
        }
      }
    });
  }

  void DiscoverDevice() async {
    var s = await flutterBlue.connectedDevices;
    if (s.length != 0) {
      if (s[0].name.toString() == "MyESP32") {
        print("Senddddddddd");
        DiscoverSerives(s[0]);
        // flutterBlue.stopScan();
      }
    } else {
      // Start scanning
      flutterBlue.startScan(timeout: Duration(seconds: 4));
      // Listen to scan results
      flutterBlue.scanResults.listen((results) {
        // do something with scan results
        for (ScanResult r in results) {
          print('${r.device.name} found : ${r.device.id}');
          if (r.device.name.toString() == "MyESP32") {
            print(r.device);
            connectBLEDevice(r.device);
          }
        }
      });
      // Stop scanning
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
