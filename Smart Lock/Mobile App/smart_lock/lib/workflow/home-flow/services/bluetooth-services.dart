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
    FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 4));
  }

  void connectBLEDevice(BluetoothDevice device) async {
    print("connecting");
    await device.connect(autoConnect: false);
    print("connected");
    DiscoverSerives(device);
  }

  void DiscoverSerives(d) async {
    print("hiiiiiiiiiiii");
    List<BluetoothService> services = await d.discoverServices();
    services.forEach((service) async {
      print(service);
      if (service.uuid.toString() == "28406d0e-73e1-11ed-a1eb-0242ac120002") {
        print("Searchedddddddd");
        List<BluetoothCharacteristic> characteristics = service.characteristics;
        for (BluetoothCharacteristic characteristic in characteristics) {
          print("**********************************");
          print(characteristic);
          print("**********************************");
          if (characteristic.uuid.toString() ==
              "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
            List<int> value = await characteristic.read();
            print(value);
            await characteristic.write([0x12, 0x34]);

            print("GooooooooooooooooooooooD");
          }
        }
      }
      // do something with service
    });
  }

  void DiscoverDevice() async {
    var s = await flutterBlue.connectedDevices;
    try {
      if (s.length != 0) {
        if (s[0].id.toString() == "30:AE:A4:84:26:AA") {
          print("Senddddddddd");
          DiscoverSerives(s[0]);
          flutterBlue.stopScan();
        }
      } else {
        // Start scanning
        flutterBlue.startScan(timeout: Duration(seconds: 4));
        // Listen to scan results
        flutterBlue.scanResults.listen((results) {
          // do something with scan results
          for (ScanResult r in results) {
            print('${r.device.name} found : ${r.device.id}');
            if (r.device.id.toString() == "30:AE:A4:84:26:AA") {
              print(r.device);
              connectBLEDevice(r.device);
            }
          }
        });
        // Stop scanning
        flutterBlue.stopScan();
      }
    } catch (e) {
      print(e);
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
