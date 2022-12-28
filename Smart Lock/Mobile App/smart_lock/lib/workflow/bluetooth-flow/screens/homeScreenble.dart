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
                  CupertinoButton(child: Text(""), onPressed: () {}),
                  CupertinoSwitch(
                    activeColor: Colors.white54,
                    value: deviceState[0]!,
                    onChanged: (val) {
                      setState(() {
                        deviceState[0] = val;
                        BluetoothPackage.instance.writeWiFiCreds(val, 1);
                      });
                    },
                  ),
                ],
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 100,
                  crossAxisSpacing: 15.0,
                  mainAxisSpacing: 15.0,
                  childAspectRatio: 1,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Text("Hi");
                },
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
