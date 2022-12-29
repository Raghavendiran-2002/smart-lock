import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothPackage {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  late BluetoothDevice connectedDevice;
  bool isConnected = false;
  bool isDisconnected = true;

  void connectBLEDevice(BluetoothDevice device) async {
    // await device.connect();
    await device.connect(autoConnect: true).catchError((error) async {
      await device.disconnect();
      await Future.delayed(Duration(seconds: 2));
      discoverDevice();
    });
    isDisconnected = false;
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
        if (eachDevice.id.toString() == "94:B9:7E:D5:CD:F6") {
          isDisconnected = false;
          connectedDevice = eachDevice;
          isConnected = true;
        } else {
          isDisconnected = true;
          isConnected = false;
          discoverDevice();
        }
      });
    });
  }

  void actuateRelay(deviceState, deviceID) async {
    await flutterBlue.connectedDevices.then((value) {
      value.forEach((BluetoothDevice eachDevice) {
        print(eachDevice.id);
        if (eachDevice.id.toString() == "94:B9:7E:D5:CD:F6") {
          isDisconnected = false;
        } else {
          isDisconnected = true;
        }
      });
    });

    List<BluetoothService> services = await connectedDevice.discoverServices();
    for (int j = 0; j < services.length; j++) {
      if (services[j].uuid.toString() ==
          "28406d0e-73e1-11ed-a1eb-0242ac120002") {
        isDisconnected = false;
        List<BluetoothCharacteristic> characteristicsList =
            services[j].characteristics;
        for (int i = 0; i < characteristicsList.length; i++) {
          if (characteristicsList[i].uuid.toString() ==
              "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
            final json =
                '{ "deviceState": $deviceState , "deviceID": $deviceID}';
            try {
              await characteristicsList[i].write(json.codeUnits);
              isConnected = true;
            } catch (e) {
              print(e);
              print('*********');
              isDisconnected = true;
              if (e == "Exception: Failed to write the characteristic") {
                isConnected = false;
              }
            }
            // List<int> value = await characteristicsList[i].read();
            //
            // var verifyValue = String.fromCharCodes(value);
            // if (verifyValue == json) {
            // } else {}
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
        if (eachDevice.id.toString() == "94:B9:7E:D5:CD:F6") {
          initServiceCharacteristic(eachDevice);
          isDisconnected = false;
          connectedDevice = eachDevice;
          isConnected = true;
        }
      });
      flutterBlue.startScan(timeout: Duration(seconds: 1));
      bool isFirst = true;
      flutterBlue.scanResults.listen((results) {
        for (ScanResult r in results) {
          // print('Devicesss  : ${r}');
          if (r.device.id.toString() == "94:B9:7E:D5:CD:F6" && isFirst) {
            isDisconnected = false;
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
