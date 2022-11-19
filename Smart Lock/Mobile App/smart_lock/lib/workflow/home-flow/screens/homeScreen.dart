import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;

  void fetchData() async {
    readingObjects.clear();
    setState(() {
      isLoading = true;
    });
    try {
      Dio dioInstance = Dio();
      var response = await dioInstance
          .get('http://43.204.238.31/quality/getByNode/device1');

      deserializeJSON(response.data["values"]);
    } catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  List<Reading> readingObjects = [];

  void deserializeJSON(List readings) {
    int count = 0;
    for (Map reading in readings.reversed) {
      if (count == 15) break;
      count++;
      readingObjects.add(
        Reading(
          atTemp: reading["atmosphericTemperature"],
          waterTemp: reading["waterTemperature"],
          turbidity: reading["turbidity"],
          tds: reading["tds"],
          tss: reading["tss"],
          pH: reading["pH"],
          spO2: reading["disOxygen"],
          timestamp: reading["createdAt"],
          aquamanScore: reading["scale"],
          xMap: 15 - count,
        ),
      );
    }
  }

  bool alertPresent = true;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  bool displayAlert = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF666CDB),
        centerTitle: true,
        title: Text(
          "TORQ - RiG'22",
          style: TextStyle(
            fontFamily: "Poppins",
          ),
        ),
        actions: [
          IconButton(
            onPressed: fetchData,
            icon: Icon(
              Icons.refresh,
            ),
          ),
        ],
        leading: IconButton(
          onPressed: () async {
            FirebaseAuth.instance.signOut();
            GoogleSignIn().signOut();
            Navigator.pushNamedAndRemoveUntil(
                context, "login", (Route<dynamic> route) => false);
          },
          icon: Icon(
            Icons.logout,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : readingObjects.isEmpty
              ? Center(
                  child: Text(
                    "No data available!",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: Color(0xFF4F4D76),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                )
              : SafeArea(
                  child: ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          height: 165,
                          child: GridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFEEEEFF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      readingObjects[0].tds.toStringAsFixed(2),
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        color: Color(0xFF4F4D76),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      "TDS",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        color: Color(0xFF4F4D76),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFEEEEFF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      readingObjects[0]
                                          .turbidity
                                          .toStringAsFixed(2),
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        color: Color(0xFF4F4D76),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      "Turbidity",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        color: Color(0xFF4F4D76),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFEEEEFF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "5.1",
                                      // readingObjects[0].pH.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        color: Color(0xFF4F4D76),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      "pH",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        color: Color(0xFF4F4D76),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFEEEEFF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      readingObjects[0]
                                          .waterTemp
                                          .toStringAsFixed(1),
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        color: Color(0xFF4F4D76),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      "Water Temperature",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        color: Color(0xFF4F4D76),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 25),
                          decoration: BoxDecoration(
                            color: readingObjects[0].aquamanScore <= 3
                                ? Colors.red
                                : readingObjects[0].aquamanScore <= 5
                                    ? Colors.yellow
                                    : Colors.green,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: Text(
                              readingObjects[0].aquamanScore <= 3
                                  ? "Not fit for use"
                                  : readingObjects[0].aquamanScore <= 5
                                      ? "Use with Caution"
                                      : "Usable Quality",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 35),
                        child: Text(
                          "Historical Analysis",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            color: Color(0xFF4F4D76),
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                ),
    );
  }
}

class Reading {
  late double atTemp;
  late double waterTemp;
  late double turbidity;
  late double tds;
  late double tss;
  late double pH;
  late double spO2;
  late DateTime timestamp;
  late double aquamanScore;
  late int xMap;
  Reading(
      {required String atTemp,
      required String waterTemp,
      required String turbidity,
      required String tds,
      required String tss,
      required String pH,
      required String spO2,
      required String timestamp,
      required aquamanScore,
      required xMap}) {
    this.atTemp = double.parse(atTemp);
    this.waterTemp = double.parse(waterTemp);
    this.tds = double.parse(tds);
    this.tss = double.parse(tss);
    this.pH = double.parse(pH);
    this.turbidity = double.parse(turbidity);
    this.spO2 = double.parse(spO2);
    this.timestamp = DateTime.parse(timestamp);
    this.aquamanScore = aquamanScore;
    this.xMap = xMap;
  }
}
