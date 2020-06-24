import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:health_data/health_data.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List<HealthDataPoint> stepsByDay = [];
  bool _isAuthorized;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    DateTime now = DateTime.now().add(Duration(days: 1));
    DateTime endDate = DateTime(now.year, now.month, now.day, 0, 0);
    DateTime startDate = endDate.add(Duration(days: -365));

    print("StartDate - ${DateFormat.yMd().add_jm().format(startDate)}");
    print("EndDate - ${DateFormat.yMd().add_jm().format(endDate)}");

    Future.delayed(Duration(seconds: 2), () async {
      _isAuthorized = await HealthData.requestAuthorization();

      if (_isAuthorized) {
        print('Authorized');
      }

      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        // platformVersion = await HealthData.platformVersion;
        // List<HealthDataPoint> weight = await HealthData.getDataLatestAvailable(HealthDataType.WEIGHT);
        // List<HealthDataPoint> height = await HealthData.getDataLatestAvailable(HealthDataType.HEIGHT);
        // List<HealthDataPoint> bodyFat = await HealthData.getDataLatestAvailable(HealthDataType.BODY_FAT_PERCENTAGE);
        // List<HealthDataPoint> waistCircumfrence = await HealthData.getDataLatestAvailable(HealthDataType.WAIST_CIRCUMFERENCE);
        // List<HealthDataPoint> bmi = await HealthData.getDataLatestAvailable(HealthDataType.BODY_MASS_INDEX);
        List<HealthDataPoint> sys =
            await HealthData.getDataByStartAndEndDate(startDate, endDate, HealthDataType.BLOOD_PRESSURE_SYSTOLIC);
        List<HealthDataPoint> dias =
            await HealthData.getDataByStartAndEndDate(startDate, endDate, HealthDataType.BLOOD_PRESSURE_DIASTOLIC);
        // List<HealthDataPoint> sys = await HealthData.getDataByStartAndEndDate(
        //     startDate, DateTime.now(), HealthDataType.STEPS);
        // List<HealthDataPoint> dias = await HealthData.getDataAveragedByDay(
        //     startDate, DateTime.now(), HealthDataType.HEART_RATE);
        // stepsByDay.addAll(weight);
        // stepsByDay.addAll(height);
        // stepsByDay.addAll(bodyFat);
        // stepsByDay.addAll(waistCircumfrence);
        // List<HealthDataPoint> rest = await HealthData.getDataLatestAvailable(HealthDataType.RESTING_HEART_RATE);
        // List<HealthDataPoint> walk = await HealthData.getDataLatestAvailable(HealthDataType.WALKING_HEART_RATE);
        stepsByDay.addAll(sys);
        stepsByDay.addAll(dias);
      } on PlatformException {
        platformVersion = 'Failed to get platform version.';
      }

      /// Print the results
      for (var x in stepsByDay) {
        print("Data point: $x");
      }

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      setState(() {
        _platformVersion = platformVersion;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
