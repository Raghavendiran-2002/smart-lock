import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:smart_lock/workflow/bluetooth-flow/services/bleService.dart';

class HomeScreenBluetooth extends StatefulWidget {
  const HomeScreenBluetooth({Key? key}) : super(key: key);

  @override
  State<HomeScreenBluetooth> createState() => _HomeScreenBluetoothState();
}

class _HomeScreenBluetoothState extends State<HomeScreenBluetooth> {
  List<bool> deviceState = [false, false, false, false];
  List<int> deviceID = [1, 2, 3, 4];
  List deviceType = ["lamp", "fan", "tv", "lamp"];

  @override
  void initState() {
    connectBluetoothDevice();
    BluetoothPackage.instance.isDeviceConnected();
  }

  void connectBluetoothDevice() async {
    bool bluetoothON = await FlutterBluePlus.instance.isOn;
    bluetoothON
        ? BluetoothPackage.instance.discoverDevice()
        : reconnectDevice();
  }

  void reconnectDevice() {
    FlutterBluePlus.instance.turnOn();
    connectBluetoothDevice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              BluetoothPackage.instance.isDisconnected
                  ? Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                      decoration: BoxDecoration(
                        color: Color(0xFFC5A0AA),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "Disconnected",
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  : Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                      decoration: BoxDecoration(
                        color: BluetoothPackage.instance.isConnected
                            ? Color(0xFFDBDBFC)
                            : Color(0xFFA7C4AD),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        BluetoothPackage.instance.isConnected
                            ? "Connect"
                            : "Reconnecting",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
              Expanded(
                child: GridView.builder(
                  // padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: 4,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 100,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        bool val;
                        deviceState[index] ? val = false : val = true;
                        BluetoothPackage.instance.actuateRelay(val, index);
                        setState(() {
                          deviceState[index] = val;
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                        decoration: BoxDecoration(
                          color: deviceState[index]
                              ? Color(0xFF6171DC)
                              : Color(0xFFDBDBFC),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                deviceIconWidget(
                                    deviceType[index], deviceState[index]),
                                Transform.scale(
                                  scale: 1,
                                  child: CupertinoSwitch(
                                    activeColor: Colors.white54,
                                    value: deviceState[index],
                                    onChanged: (val) {
                                      deviceState[index] = val;
                                      BluetoothPackage.instance
                                          .actuateRelay(val, index);
                                      setState(() {
                                        deviceState[index] = val;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                deviceState[index]
                                    ? Text(
                                        "ON",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      )
                                    : Text(
                                        "OFF",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  connectBluetoothDevice();
                  BluetoothPackage.instance.isDeviceConnected();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                  decoration: BoxDecoration(
                    color: Color(0xFF6171DC),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "Reconnect",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class deviceIconWidget extends StatelessWidget {
  late String? icon;
  late bool? deviceState;
  deviceIconWidget(this.icon, this.deviceState);

  @override
  Widget build(BuildContext context) {
    Map<bool, Color> iconColoring = {
      true: Colors.white,
      false: Color(0xFF6171DC),
    };
    Map<String, IconData> iconMapping = {
      'lock': CupertinoIcons.lock,
      'lamp': CupertinoIcons.lightbulb,
      'fan': CupertinoIcons.dial_fill,
      'tv': CupertinoIcons.tv,
    };
    Map<String, IconData> iconMappings = {
      'lock': CupertinoIcons.lock,
      'lamp': CupertinoIcons.lightbulb,
      'fan': CupertinoIcons.dial_fill,
      'tv': CupertinoIcons.tv,
    };
    return Icon(deviceState! ? iconMapping[icon] : iconMappings[icon],
        color: iconColoring[deviceState], size: 50);
  }
}
