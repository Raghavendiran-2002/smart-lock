import 'dart:convert';
import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothPackage {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  // late BluetoothDevice connectedDevice;
  late BluetoothDevice connectedDevice;
  void connectBLEDevice(BluetoothDevice device) async {
    print("Connecting");
    await device.connect(autoConnect: false);
    initServiceCharacteristic(device);
  }

  void initServiceCharacteristic(Device) async {
    List<BluetoothService> services = await Device.discoverServices();

    for (int j = 0; j < services.length; j++) {
      if (services[j].uuid.toString() ==
          "28406d0e-73e1-11ed-a1eb-0242ac120002") {
        List<BluetoothCharacteristic> characteristicsList =
            services[j].characteristics;
        for (int i = 0; i < characteristicsList.length; i++) {
          if (characteristicsList[i].uuid.toString() ==
              "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
            readValue(characteristicsList[i]);
          }
        }
      }
    }
  }

  void writeWiFiCreds(deviceState, deviceID) async {
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
            final json =
                '{ "deviceState": $deviceState , "deviceID": $deviceID}';
            var k = jsonDecode(json);
            print(k['deviceState']);
            await characteristicsList[i].write(json.codeUnits);
          }
        }
      }
    }

    // services.forEach((BluetoothService eachservices) {
    //   if (eachservices.uuid.toString() ==
    //       "28406d0e-73e1-11ed-a1eb-0242ac120002") {
    //     List<BluetoothCharacteristic> characteristicsList =
    //         eachservices.characteristics;
    //     characteristicsList
    //         .forEach((BluetoothCharacteristic eachCharacteristics) {
    //       if (eachCharacteristics.uuid.toString() ==
    //           "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
    //         readValue(eachCharacteristics);
    //         print("**************************************");
    //         // print(msg['wifi']);
    //         writeValue("json", eachCharacteristics);
    //       }
    //     });
    //   }
    // });
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

  void writeValue(
      var deviceID, var deviceState, BluetoothCharacteristic ble) async {
    print("Startted");
    final json = '{ "deviceState": $deviceState , "deviceID": $deviceID}';
    var k = jsonDecode(json);
    print(k['deviceState']);

    await ble.write([0, 0], withoutResponse: true);
    // print(); // deviceState
    // await ble.write(msg.codeUnits);
  }

  void discoverDevice() async {
    late bool isConnected;
    await flutterBlue.connectedDevices.then((value) {
      value.forEach((BluetoothDevice eachDevice) {
        if (eachDevice.id.toString() == "E0:E2:E6:0B:58:6E") {
          initServiceCharacteristic(eachDevice);
          connectedDevice = eachDevice;
          isConnected = true;
        }
      });

      flutterBlue.startScan(timeout: Duration(seconds: 1));
      bool isFirst = true;
      flutterBlue.scanResults.listen((results) {
        for (ScanResult r in results) {
          // print('Devicesss  : ${r}');
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
    });
    // isConnected == null ? isConnected = true : isConnected = false;
    // print(isConnected);
    // return isConnected;
  }

  BluetoothPackage._();

  static final instance = BluetoothPackage._();
}
