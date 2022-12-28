import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
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
  bool isBluetoothOn = true;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    isBluetoothON();
    ConnectDevice("28406d0e-73e1-11ed-a1eb-0242ac120002", _btnController);
  }

  void isBluetoothON() async {
    bool blestate = await FlutterBluePlus.instance.isOn;
    print(blestate);
    setState(() {
      isBluetoothOn = blestate;
    });
  }

  void turnBluetoothON() {
    FlutterBluePlus.instance.turnOn();
    print("Turinmdlgnsdk;");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  BluetoothPackage.instance.writeWiFiCreds("hei", "ifdohj");
                  // ConnectDevice(
                  //     "28406d0e-73e1-11ed-a1eb-0242ac120002", _btnController);
                  print("connected");
                },
                child: Text("Connect"),
              ),
              Row(
                children: [
                  Text(
                    "Connect",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
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
                        BluetoothPackage.instance.writeWiFiCreds(val, index);
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
                                    value: deviceState[index]!,
                                    onChanged: (val) {
                                      deviceState[index] = val;
                                      BluetoothPackage.instance
                                          .writeWiFiCreds(val, index);
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
                                deviceState[index]!
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
            ],
          ),
        ),
      ),
    );
  }

  void ConnectDevice(
      uniqueCode, RoundedLoadingButtonController controller) async {
    Future<bool> isConnected;
    if (isBluetoothOn == true) {
      BluetoothPackage.instance.discoverDevice();
      // .discoverDevice("28406d0e-73e1-11ed-a1eb-0242ac120002");
      print("*****************************************");
      // print(await isConnected);
      print("*****************************************");
      // BluetoothPackage.instance.writeWiFiCreds("hei", "ifdohj");
      // CustomBluetoothImplementation.instance.writeValue("Helloworld!!",)

    } else {
      Alert(
        context: context,
        type: AlertType.error,
        title: "bluetooth is turned off",
        buttons: [
          DialogButton(
            child: Text(
              "turn on",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              turnBluetoothON();
              Navigator.pop(context);
            },
            width: 120,
          ),
          DialogButton(
            child: Text(
              "close",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          ),
        ],
      ).show();
    }
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
