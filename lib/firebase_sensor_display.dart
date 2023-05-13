import 'package:day13/constants.dart';
import 'package:day13/widgets/reusable_card.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class FirebaseSensorDisplay extends StatefulWidget {
  final uid = FirebaseAuth.instance.currentUser.uid;

  @override
  _FirebaseSensorDisplayState createState() => _FirebaseSensorDisplayState();
}

class _FirebaseSensorDisplayState extends State<FirebaseSensorDisplay> {
  final temperatureNotifier = ValueNotifier(0.0);
  final humidityNotifier = ValueNotifier(0.0);
  final batteryNotifier = ValueNotifier(0.0);
  final moistureNotifier = ValueNotifier(0.0);
  final waterLevelNotifier = ValueNotifier(0.0);
  final waterAmountNotifier = ValueNotifier(0.0);
  final waterAmountController = TextEditingController();

  String wifiPassword;
  String userPassword;
  String ipAddress;

  bool _isLoading = false;
  String _loadingState = "Connecting";

  @override
  void initState() {
    super.initState();
    final databaseReference = FirebaseDatabase.instance.ref();

    databaseReference.child(widget.uid).onValue.listen((event) {
      setState(() {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        temperatureNotifier.value = double.parse(data["temperature"]);
        humidityNotifier.value = double.parse(data["humidity"]);
        batteryNotifier.value = double.parse(data["battery"]);
        moistureNotifier.value = double.parse(data["moisture"]);
        waterLevelNotifier.value = double.parse(data["distance"]);
        waterAmountNotifier.value =
            double.parse(data["waterAmount"].toString());
      });
    });
  }

  @override
  void dispose() {
    temperatureNotifier.dispose();
    humidityNotifier.dispose();
    batteryNotifier.dispose();
    moistureNotifier.dispose();
    waterLevelNotifier.dispose();
    waterAmountNotifier.dispose();
    waterAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Color(0xFF55796C),
          Color(0xFF1A2E28),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: CustomScrollView(slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: ReusableCard(
                        color: [Color(0xFFFAF6E8), Color(0xFFE7E6DC)],
                        cardChild: Container(
                            padding: EdgeInsets.only(left: 20),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Sensor Data', style: kSensorDisplayTitle),
                                Text(
                                  'Welcome Back. Here is your current system status.',
                                  style: kDescriptionTextStyle,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Color(0xFF2D3C35),
                                          title: Text(
                                            "Device Wi-Fi Setup",
                                            style: kDeviceSetupTitleTextStyle,
                                          ),
                                          content: TextField(
                                            style: kPasswordLabelTextStyle,
                                            cursorColor: Color(0xFFD29644),
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color(0xFFD29644)),
                                              ),
                                              labelStyle:
                                                  kPasswordLabelTextStyle,
                                              labelText:
                                                  "Please enter your Wi-Fi Password",
                                              fillColor: Colors.white,
                                              filled: false,
                                            ),
                                            onChanged: (String value) {
                                              wifiPassword = value;
                                            },
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text(
                                                "OK",
                                                style:
                                                    kConfigureButtonTextStyle,
                                              ),
                                              onPressed: () async {
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                executeEspTouch(
                                                    userPassword, wifiPassword);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    'Device setup',
                                    style: kConfigureButtonTextStyle,
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ),
                    _isLoading
                        ? Expanded(
                            flex: 4,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Text(
                                      _loadingState,
                                      style: kNotifierStyle,
                                    ),
                                  ),
                                  CircularProgressIndicator(
                                    color: Color(0xFFD29644),
                                    strokeWidth: 10,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Expanded(
                            flex: 5,
                            child: ReusableCard(
                              padding: EdgeInsets.all(15),
                              color: [Color(0xFFFBE5B4), Color(0xFFE4C99C)],
                              cardChild: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ValueListenableBuilder(
                                              valueListenable:
                                                  temperatureNotifier,
                                              builder: (context, temperature,
                                                  child) {
                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 20),
                                                      child:
                                                          SimpleCircularProgressBar(
                                                        animationDuration: 0,
                                                        mergeMode: true,
                                                        onGetText:
                                                            (double value) {
                                                          return Text(
                                                            '${value.toInt()}°C',
                                                            style:
                                                                kNotifierStyle,
                                                          );
                                                        },
                                                        size: 50,
                                                        maxValue: 40,
                                                        valueNotifier:
                                                            temperatureNotifier,
                                                        progressColors: const [
                                                          Color(0xFFD29644)
                                                        ],
                                                        backColor:
                                                            Colors.transparent,
                                                        backStrokeWidth: 0,
                                                        progressStrokeWidth: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Temperature',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: kMetricStyle,
                                                    ),
                                                  ],
                                                );
                                              }),
                                          ValueListenableBuilder(
                                              valueListenable: humidityNotifier,
                                              builder:
                                                  (context, humidity, child) {
                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 20),
                                                      child:
                                                          SimpleCircularProgressBar(
                                                        animationDuration: 0,
                                                        mergeMode: true,
                                                        onGetText:
                                                            (double value) {
                                                          return Text(
                                                            '${value.toInt()}%',
                                                            style:
                                                                kNotifierStyle,
                                                          );
                                                        },
                                                        size: 50,
                                                        valueNotifier:
                                                            humidityNotifier,
                                                        progressColors: const [
                                                          Color(0xFFD29644)
                                                        ],
                                                        backColor:
                                                            Colors.transparent,
                                                        backStrokeWidth: 0,
                                                        progressStrokeWidth: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Humidity',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: kMetricStyle,
                                                    ),
                                                  ],
                                                );
                                              }),
                                          ValueListenableBuilder(
                                              valueListenable: batteryNotifier,
                                              builder:
                                                  (context, battery, child) {
                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 20),
                                                      child:
                                                          SimpleCircularProgressBar(
                                                        animationDuration: 0,
                                                        size: 50,
                                                        valueNotifier:
                                                            batteryNotifier,
                                                        progressColors: const [
                                                          Color(0xFFD29644)
                                                        ],
                                                        backColor:
                                                            Colors.transparent,
                                                        onGetText:
                                                            (double value) {
                                                          return Text(
                                                            battery > 100 ||
                                                                    battery < 0
                                                                ? 'N/A'
                                                                : '${value.toInt()}%',
                                                            style:
                                                                kNotifierStyle,
                                                          );
                                                        },
                                                        mergeMode: true,
                                                        backStrokeWidth: 0,
                                                        progressStrokeWidth: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Battery',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: kMetricStyle,
                                                    ),
                                                  ],
                                                );
                                              }),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ValueListenableBuilder(
                                              valueListenable:
                                                  waterLevelNotifier,
                                              builder:
                                                  (context, waterLevel, child) {
                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 20),
                                                      child:
                                                          SimpleCircularProgressBar(
                                                        animationDuration: 0,
                                                        mergeMode: true,
                                                        maxValue: 2650,
                                                        onGetText:
                                                            (double value) {
                                                          return Text(
                                                            '${value.toInt()} mL',
                                                            style:
                                                                kNotifierStyle,
                                                          );
                                                        },
                                                        size: 70,
                                                        valueNotifier:
                                                            waterLevelNotifier,
                                                        progressColors: const [
                                                          Color(0xFFD29644)
                                                        ],
                                                        backColor:
                                                            Colors.transparent,
                                                        backStrokeWidth: 0,
                                                        progressStrokeWidth: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Water Level',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: kMetricStyle,
                                                    ),
                                                  ],
                                                );
                                              }),
                                          ValueListenableBuilder(
                                              valueListenable: moistureNotifier,
                                              builder:
                                                  (context, moisture, child) {
                                                return Column(
                                                  children: [
                                                    Text(
                                                      'Moisture',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: kMetricStyle,
                                                    ),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 10),
                                                        child: moistureNotifier
                                                                    .value <=
                                                                20
                                                            ? Text(
                                                                'Dry',
                                                                style:
                                                                    kMoistureTextStyle,
                                                              )
                                                            : moistureNotifier
                                                                            .value >
                                                                        20 &&
                                                                    moistureNotifier
                                                                            .value <=
                                                                        40
                                                                ? Text(
                                                                    'Moist',
                                                                    style:
                                                                        kMoistureTextStyle,
                                                                  )
                                                                : Text(
                                                                    'Wet',
                                                                    style:
                                                                        kMoistureTextStyle,
                                                                  )),
                                                  ],
                                                );
                                              }),
                                          ValueListenableBuilder(
                                              valueListenable:
                                                  waterAmountNotifier,
                                              builder:
                                                  (context, humidity, child) {
                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 20),
                                                      child:
                                                          SimpleCircularProgressBar(
                                                        animationDuration: 0,
                                                        mergeMode: true,
                                                        maxValue: 500,
                                                        onGetText:
                                                            (double value) {
                                                          return Text(
                                                            '${value.toInt()} mL',
                                                            style:
                                                                kNotifierStyle,
                                                          );
                                                        },
                                                        size: 70,
                                                        valueNotifier:
                                                            waterAmountNotifier,
                                                        progressColors: const [
                                                          Color(0xFFD29644)
                                                        ],
                                                        backColor:
                                                            Colors.transparent,
                                                        backStrokeWidth: 0,
                                                        progressStrokeWidth: 10,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Dispensed Amount',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: kMetricStyle,
                                                    ),
                                                  ],
                                                );
                                              }),
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                    Expanded(
                      flex: 2,
                      child: ReusableCard(
                        padding: EdgeInsets.all(12),
                        color: [Color(0xFF495B56), Color(0xFF2D3C35)],
                        cardChild: Column(
                          children: [
                            TextField(
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Colors.white),
                              controller: waterAmountController,
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                labelText: 'Enter water amount',
                                labelStyle: kWaterTextStyle,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 30.0, left: 10.0, right: 10.0),
                              child: InkWell(
                                onTap: () {
                                  final databaseReference =
                                      FirebaseDatabase.instance.ref();
                                  databaseReference
                                      .child(widget.uid)
                                      .child("waterAmount")
                                      .set(double.parse(
                                          waterAmountController.text));
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF1A2E28),
                                        blurRadius: 15,
                                        offset: Offset(0, 0),
                                      )
                                    ],
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFE3B360),
                                        Color(0xFFD29644),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.check,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                        },
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.symmetric(
                              horizontal: 60, vertical: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Color(0xA0D29644),
                          ),
                          child: Center(
                            child: Text(
                              "Sign Out",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void executeEspTouch(String userPassword, String wifiPassword) async {
    await Geolocator.requestPermission();
    final info = NetworkInfo();
    String ssid = await info.getWifiName();
    String bssid = await info.getWifiBSSID();
    ssid = ssid.replaceAll('"', '');
    setState(() {
      _isLoading = true;
    });

    final provisioner = Provisioner.espTouch();

    provisioner.listen((p0) async {
      print("Device $p0 has been connected to Wi-Fi");
      ipAddress = p0.ipAddressText;
      print(ssid + wifiPassword + bssid);
      setState(() {
        _loadingState = "Connected";
      });
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _isLoading = false;
      });
      _loadingState = "Connecting";
    });

    await provisioner.start(ProvisioningRequest.fromStrings(
        ssid: ssid, bssid: bssid, password: wifiPassword));

    await Future.delayed(Duration(seconds: 45));

    setState(() {
      _loadingState = "Unable to connect";
    });

    await Future.delayed(Duration(milliseconds: 250));

    setState(() {
      _isLoading = false;
    });
    provisioner.stop();
    _loadingState = "Connecting";
  }
}
