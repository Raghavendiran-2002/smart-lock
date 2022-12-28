import 'dart:math';

import 'package:flutter_blue/flutter_blue.dart';

class BluetoothPackage {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  // late BluetoothDevice connectedDevice;
  late BluetoothDevice connectedDevice;
  void connectBLEDevice(BluetoothDevice device) async {
    print("Connecting");
    await device.connect(autoConnect: true);
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
        // final json = '{ "status": "Ready" }';
        // var k = jsonDecode(json);
        // print(k['status']);
        // writeValue(k, characteristics[0]);
      }
    }
  }

  void writeWiFiCreds(wifi, passwd) async {
    print(connectedDevice);
    List<BluetoothService> services = await connectedDevice.discoverServices();
    print(services);
    print(services.length);

    for (int j = 0; j < services.length; j++) {
      if (services[j].uuid.toString() ==
          "28406d0e-73e1-11ed-a1eb-0242ac120002") {
        List<BluetoothCharacteristic> characteristicsList =
            services[j].characteristics;
        for (int i = 0; i < characteristicsList.length; i++) {
          if (characteristicsList[i].uuid.toString() ==
              "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
            readValue(characteristicsList[i]);
            print("**************************************");
            // print(msg['wifi']);
            writeValue("json", characteristicsList[i]);
          }
        }
      }
    }

    services.forEach((BluetoothService eachservices) {
      if (eachservices.uuid.toString() ==
          "28406d0e-73e1-11ed-a1eb-0242ac120002") {
        List<BluetoothCharacteristic> characteristicsList =
            eachservices.characteristics;
        characteristicsList
            .forEach((BluetoothCharacteristic eachCharacteristics) {
          if (eachCharacteristics.uuid.toString() ==
              "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
            readValue(eachCharacteristics);
            print("**************************************");
            // print(msg['wifi']);
            writeValue("json", eachCharacteristics);
          }
        });
      }
    });
  }

  void readValue(BluetoothCharacteristic ble) async {
    List<int> value = await ble.read();
    // await ble.read().
    // print(value);
    // print(String.fromCharCode(value[0]));
    print(String.fromCharCodes(value));
  }

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  void writeValue(String msg, BluetoothCharacteristic ble) async {
    print("Startted");
    // var s = await ble.write([0x12]);
    // await ble.write(_getRandomBytes(), withoutResponse: true);
    await ble.write([0, 0], withoutResponse: true);
    // print();
    // await ble.write(msg.codeUnits);
  }

  void discoverDevice() async {
    late bool isConnected;
    await flutterBlue.connectedDevices.then((value) {
      if (value.length != 0) {
        if (value[0].id.toString() == "E0:E2:E6:0B:58:6E") {
          initServiceCharacteristic(value[0]);
          connectedDevice = value[0];
          isConnected = true;
        }
      } else {
        flutterBlue.startScan(timeout: Duration(seconds: 1));
        bool isFirst = true;
        flutterBlue.scanResults.listen((results) {
          for (ScanResult r in results) {
            print('Devicesss  : ${r}');
            if (r.device.id.toString() == "E0:E2:E6:0B:58:6E" && isFirst) {
              print("Gotttttttttttt Youuuuuuuuuuu");
              connectedDevice = r.device;
              connectBLEDevice(r.device);
              isConnected = true;
              isFirst = false;
              // flutterBlue.stopScan();
              // initServiceCharacteristic(value[0]);
              // break;
            }
          }
        });
      }
    });
    // isConnected == null ? isConnected = true : isConnected = false;
    // print(isConnected);
    // return isConnected;
  }

  BluetoothPackage._();

  static final instance = BluetoothPackage._();
}
