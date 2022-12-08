import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class CustomBluetoothImplementation {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  late BluetoothDevice connectedDevice;
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
        final json = '{ "status": "Ready" }';
        var k = jsonDecode(json);
        print(k['status']);
        writeValue(k, characteristics[0]);
      }
    }
  }

  void writeWiFiCreds(wifi, passwd) async {
    List<BluetoothService> services = await connectedDevice.discoverServices();
    if (services[0].uuid.toString() == "28406d0e-73e1-11ed-a1eb-0242ac120002") {
      List<BluetoothCharacteristic> characteristics =
          services[0].characteristics;
      if (characteristics[0].uuid.toString() ==
          "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
        readValue(characteristics[0]);
        final json = '{ "wifi": "${wifi}", "passwd" : "${passwd}" }';
        var msg = jsonDecode(json);
        print(msg['wifi']);
        writeValue(json, characteristics[0]);
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

  Future<bool> discoverDevice(String UID) async {
    bool isConnected = false;
    await flutterBlue.connectedDevices.then((value) {
      if (value.length != 0) {
        if (value[0].id.toString() == UID) {
          initServiceCharacteristic(value[0]);
          connectedDevice = value[0];
          isConnected = true;
        }
      } else {
        flutterBlue.startScan(timeout: Duration(seconds: 1));
        bool isFirst = true;
        flutterBlue.scanResults.listen((results) {
          for (ScanResult r in results) {
            if (r.device.id.toString() == UID && isFirst) {
              connectedDevice = r.device;
              connectBLEDevice(r.device);
              isConnected = true;
              isFirst = false;
              flutterBlue.stopScan();
              break;
            }
          }
        });
      }
    });
    // isConnected == null ? isConnected = true : isConnected = false;
    print(isConnected);
    return isConnected;
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

  CustomBluetoothImplementation._();

  /// the one and only instance of this singleton
  static final instance = CustomBluetoothImplementation._();
}
