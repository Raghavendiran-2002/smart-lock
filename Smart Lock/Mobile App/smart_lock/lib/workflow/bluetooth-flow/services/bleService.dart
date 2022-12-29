import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothPackage {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  late BluetoothDevice connectedDevice;
  bool isConnected = false;

  void connectBLEDevice(BluetoothDevice device) async {
    // await device.connect();
    await device.connect(autoConnect: true).catchError((error) async {
      await device.disconnect();
      await Future.delayed(Duration(seconds: 2));
      discoverDevice();
    });

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
            print("readinggggg");
            List<int> value = await characteristicsList[i].read();
            var results = String.fromCharCodes(value);
            print(results);
            // Map<String, dynamic> result = jsonDecode(results);
            // print("${result['deviceState']}");
            flutterBlue.stopScan();
          }
        }
      }
    }
  }

  void isDeviceConnected() async {
    await flutterBlue.connectedDevices.then((value) {
      value.forEach((BluetoothDevice eachDevice) {
        if (eachDevice.id.toString() == "E0:E2:E6:0B:58:6E") {
          connectedDevice = eachDevice;
          isConnected = true;
        } else {
          discoverDevice();
        }
      });
    });
  }

  void actuateRelay(deviceState, deviceID) async {
    List<BluetoothService> services = await connectedDevice.discoverServices();
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
            await characteristicsList[i].write(json.codeUnits);
            print("************************************************");
            List<int> value = await characteristicsList[i].read();
            isConnected = true;
            var verifyValue = String.fromCharCodes(value);
            if (verifyValue == json) {
            } else {}

            print("************************************************");
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

  void writeValue(
      var deviceID, var deviceState, BluetoothCharacteristic ble) async {
    print("Startted");
    final json = '{ "deviceState": $deviceState , "deviceID": $deviceID}';
    await ble.write([0, 0], withoutResponse: true);
    // await ble.write(msg.codeUnits);
  }

  void discoverDevice() async {
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
            isConnected = true;
            connectBLEDevice(r.device);
            connectedDevice = r.device;
          }
        }
      });
    });
  }

  BluetoothPackage._();

  static final instance = BluetoothPackage._();
}
