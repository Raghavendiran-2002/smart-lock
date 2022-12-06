import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Bluetooth extends StatefulWidget {
  const Bluetooth({Key? key}) : super(key: key);

  @override
  State<Bluetooth> createState() => _BluetoothState();
}

class _BluetoothState extends State<Bluetooth> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  String UniqueCode = '0x01';

  void discoverDevice(String UID) async {
    var s = await flutterBlue.connectedDevices;
    if (s.length != 0) {
      if (s[0].id.toString() == UID) {
        initServiceCharacteristic(s[0]);
      }
    } else {
      flutterBlue.startScan(timeout: Duration(seconds: 1));
      bool isFirst = true;
      flutterBlue.scanResults.listen((results) {
        for (ScanResult r in results) {
          print('${r.device.name} found : ${r.device.id}');
          if (r.device.id.toString() == UID && isFirst) {
            connectBLEDevice(r.device);
            isFirst = false;
          }
        }
      });
      flutterBlue.stopScan();
    }
  }

  void connectBLEDevice(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
    initServiceCharacteristic(device);
  }

  void initServiceCharacteristic(Device) async {
    bool isMsgSent = false;
    List<BluetoothService> services = await Device.discoverServices();
    if (services[0].uuid.toString() == "28406d0e-73e1-11ed-a1eb-0242ac120002") {
      List<BluetoothCharacteristic> characteristics =
          services[0].characteristics;
      if (characteristics[0].uuid.toString() ==
          "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
        readValue(characteristics[0]);
        final json = '{ "name": "Pizza da Mario" }';
        var k = jsonDecode(json);
        print(k['name']);
        writeValue("hg", characteristics[0]);
      }
    }
  }

  void readValue(BluetoothCharacteristic ble) async {
    List<int> value = await ble.read();
    // await ble.read().
    // print(value);
    // print(String.fromCharCode(value[0]));
    print(String.fromCharCodes(value));
  }

  void writeValue(String msg, BluetoothCharacteristic ble) async {
    await ble.write(msg.codeUnits);
  }

  void getDevicesBleDetails(uniqueCode) {
    FirebaseFirestore.instance
        .collection("DevicesBLE")
        .doc('TWyZKbxkEnHireMaTumt')
        .get()
        .then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      // print(data['0x01']['uniqueCode']);
      // print(data['0x01']['uniqueID']);
      print("Startedd.....................");
      discoverDevice(data['0x01']['uniqueCode']);
    });
    // .where("uniqueCode", isEqualTo: UniqueCode)

    // print(det.);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              onChanged: (text) {
                UniqueCode = text;
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  hintStyle: TextStyle(color: Colors.grey[800]),
                  hintText: "Enter Unique CODE",
                  fillColor: Colors.white70),
            ),
            ElevatedButton(
              // Color(0xFF6171DC)
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF6171DC),
              ),
              onPressed: () {
                getDevicesBleDetails(UniqueCode);
              },
              child: Text(
                "Connect",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}