import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:health_data/health_data.dart';
import 'package:health_data/health_data_point.dart';
import 'package:health_data_example/data_by_day.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<HealthDataPoint> dataPointsLatest = [];
  List<HealthDataPoint> dataPointsCumulative = [];
  List<MaxAndMinHealthDataPoint> dataPointsMaxAndMin = [];
  bool _isAuthorized;
  DataByDay latest = DataByDay();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    DateTime now = DateTime.now().add(Duration(days: 1));
    DateTime endDate = DateTime(now.year, now.month, now.day, 0, 0);
    DateTime startDate = endDate.add(Duration(days: -5));

    print("StartDate - ${DateFormat.yMd().add_jm().format(startDate)}");
    print("EndDate - ${DateFormat.yMd().add_jm().format(endDate)}");

    Future.delayed(Duration(seconds: 2), () async {
      _isAuthorized = await HealthData.requestAuthorization();

      if (_isAuthorized) {
        print('Authorized');
      }

      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        // get latest
        List<HealthDataPoint> weight =
            await HealthData.getDataLatestAvailable(HealthDataType.WEIGHT);
        List<HealthDataPoint> height =
            await HealthData.getDataLatestAvailable(HealthDataType.HEIGHT);
        List<HealthDataPoint> bodyFat = await HealthData.getDataLatestAvailable(
            HealthDataType.BODY_FAT_PERCENTAGE);
        List<HealthDataPoint> bmi = await HealthData.getDataLatestAvailable(
            HealthDataType.BODY_MASS_INDEX);

        if (Platform.isIOS) {
          List<HealthDataPoint> waistCircumfrence =
              await HealthData.getDataLatestAvailable(
                  HealthDataType.WAIST_CIRCUMFERENCE);
          List<HealthDataPoint> restingHeartRate =
              await HealthData.getDataLatestAvailable(
                  HealthDataType.RESTING_HEART_RATE);
          List<HealthDataPoint> walkingHeartRate =
              await HealthData.getDataLatestAvailable(
                  HealthDataType.WALKING_HEART_RATE);
          dataPointsLatest.addAll(waistCircumfrence);
          dataPointsLatest.addAll(restingHeartRate);
          dataPointsLatest.addAll(walkingHeartRate);

          latest.waistCircumfrence = waistCircumfrence?.first?.value;
          latest.restingHeartRate = restingHeartRate?.first?.value;
          latest.walkingHeartRate = walkingHeartRate?.first?.value;
        }

        dataPointsLatest.addAll(weight);
        dataPointsLatest.addAll(height);
        dataPointsLatest.addAll(bodyFat);
        dataPointsLatest.addAll(bmi);

        // get cumulative by day
        List<HealthDataPoint> steps = await HealthData.getDataCumulativeByDay(
            startDate, endDate, HealthDataType.STEPS);
        List<HealthDataPoint> activeEnergyBurned =
            await HealthData.getDataCumulativeByDay(
                startDate, endDate, HealthDataType.ACTIVE_ENERGY_BURNED);

        if (Platform.isIOS) {
          List<HealthDataPoint> basalEnergyBurned =
              await HealthData.getDataCumulativeByDay(
                  startDate, endDate, HealthDataType.BASAL_ENERGY_BURNED);

          dataPointsCumulative.addAll(basalEnergyBurned);
        }

        dataPointsCumulative.addAll(steps);
        dataPointsCumulative.addAll(activeEnergyBurned);

        // get max and min by day
        List<MaxAndMinHealthDataPoint> systolic =
            await HealthData.getMaxAndMinValueForEachDay(
                startDate, endDate, HealthDataType.BLOOD_PRESSURE_SYSTOLIC);
        List<MaxAndMinHealthDataPoint> diastolic =
            await HealthData.getMaxAndMinValueForEachDay(
                startDate, endDate, HealthDataType.BLOOD_PRESSURE_DIASTOLIC);
        List<MaxAndMinHealthDataPoint> heartRate =
            await HealthData.getMaxAndMinValueForEachDay(
                startDate, endDate, HealthDataType.HEART_RATE);
        List<MaxAndMinHealthDataPoint> bodyTemperauture =
            await HealthData.getMaxAndMinValueForEachDay(
                startDate, endDate, HealthDataType.BODY_TEMPERATURE);
        List<MaxAndMinHealthDataPoint> bloodOxygen =
            await HealthData.getMaxAndMinValueForEachDay(
                startDate, endDate, HealthDataType.BLOOD_OXYGEN);
        List<MaxAndMinHealthDataPoint> bloodGlucose =
            await HealthData.getMaxAndMinValueForEachDay(
                startDate, endDate, HealthDataType.BLOOD_GLUCOSE);

        dataPointsMaxAndMin.addAll(systolic);
        dataPointsMaxAndMin.addAll(diastolic);
        dataPointsMaxAndMin.addAll(heartRate);
        dataPointsMaxAndMin.addAll(bodyTemperauture);
        dataPointsMaxAndMin.addAll(bloodOxygen);
        dataPointsMaxAndMin.addAll(bloodGlucose);
      } catch (exception) {
        print(exception.toString());
      }

      /// Print the results
      for (var x in dataPointsLatest) {
        print("Data point: $x");
      }

      for (var x in dataPointsCumulative) {
        print("Data point: $x");
      }

      for (var x in dataPointsMaxAndMin) {
        print("Max And Min Data point: $x");
      }

      if (!mounted) return;

      setState(() {});
    });
  }

  List<HealthDataType> _dataTypesIOS = [
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.HEIGHT,
    HealthDataType.WEIGHT,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.WAIST_CIRCUMFERENCE,
    HealthDataType.STEPS,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.WALKING_HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.ELECTRODERMAL_ACTIVITY,
    HealthDataType.HIGH_HEART_RATE_EVENT,
    HealthDataType.LOW_HEART_RATE_EVENT,
    HealthDataType.IRREGULAR_HEART_RATE_EVENT
  ];

  String getDataByDayColumnName(String dataType) {
    switch (dataType) {
      case "HEIGHT":
        return "height";
      case "WEIGHT":
        return "weight";
      case "BODY_MASS_INDEX":
        return "bodyMassIndex";
      case "BODY_FAT_PERCENTAGE":
        return "bodyFatPercent";
      case "WAIST_CIRCUMFERENCE":
        return "waistCircumfrence";
      case "RESTING_HEART_RATE":
        return "restingHeartRate";
      case "RESTING_HEART_RATE":
        return "WALKING_HEART_RATE";
      default:
        return "";
    }
  }

  mergeItAllTogether() {
    List<DataByDay> allData = [];

    DataByDay latest = DataByDay();

    dataPointsLatest.forEach((d) { 

    });
  }

  // convert values and units to standard
  String getDisplayValue(HealthDataPoint d) {
    if (d.unit == enumToString(HealthDataUnit.METERS)) {
      return HealthData.convertMetersToInches(d.value).toStringAsFixed(2);
    }
    if (d.unit == enumToString(HealthDataUnit.KILOGRAMS)) {
      return HealthData.convertKilogramsToPounds(d.value).toStringAsFixed(2);
    }
    if (d.unit == enumToString(HealthDataUnit.DEGREE_CELSIUS)) {
      return HealthData.convertCelsiusToFahrenheit(d.value).toStringAsFixed(2);
    }
    if (d.unit == enumToString(HealthDataUnit.PERCENTAGE)) {
      return (d.value * 100).toStringAsFixed(2);
    }

    return d.value.toStringAsFixed(2);
  }

  String getDisplayUnit(HealthDataPoint d) {
    if (d.unit == enumToString(HealthDataUnit.METERS)) {
      return "INCHES";
    }
    if (d.unit == enumToString(HealthDataUnit.KILOGRAMS)) {
      return "POUNDS";
    }
    if (d.unit == enumToString(HealthDataUnit.DEGREE_CELSIUS)) {
      return "DEGREE_FAHRENHEIT";
    }

    return d.unit;
  }

  List<DataRow> _buildLatestDataPoints() {
    return dataPointsLatest
        .map(
          (e) => DataRow(
            cells: [
              DataCell(
                Text(
                  DateFormat.yMd().format(
                    DateTime.fromMillisecondsSinceEpoch(e.dateFrom),
                  ),
                ),
              ),
              DataCell(Text(e.dataType)),
              DataCell(Text(getDisplayValue(e))),
              DataCell(Text(getDisplayUnit(e))),
            ],
          ),
        )
        .toList();
  }

  List<DataRow> _buildMaxAndMinDataPoints() {
    List<DataRow> rows = [];
    dataPointsMaxAndMin.forEach((e) {
      if (e.max == null || e.min == null) {
        return;
      }
      var min = DataRow(
        cells: [
          DataCell(Text(e.date)),
          DataCell(Text("${e.min.dataType}_MIN")),
          DataCell(Text(getDisplayValue(e.min))),
          DataCell(Text(getDisplayUnit(e.min))),
        ],
      );
      var max = DataRow(
        cells: [
          DataCell(Text(e.date)),
          DataCell(Text("${e.max.dataType}_MAX")),
          DataCell(Text(getDisplayValue(e.max))),
          DataCell(Text(getDisplayUnit(e.max))),
        ],
      );

      rows.add(min);
      rows.add(max);
    });
    return rows;
  }

  List<DataRow> _buildCumulativeDataPoints() {
    return dataPointsCumulative
        .map(
          (e) => DataRow(
            cells: [
              DataCell(Text(DateFormat.yMd()
                  .format(DateTime.fromMillisecondsSinceEpoch(e.dateFrom)))),
              DataCell(Text(e.dataType)),
              DataCell(Text(getDisplayValue(e))),
              DataCell(Text(e.unit)),
            ],
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('HealthData Example'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 28,
                  columns: [
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("Type")),
                    DataColumn(label: Text("Value")),
                    DataColumn(label: Text("Unit")),
                  ],
                  rows: [
                    ..._buildLatestDataPoints(),
                    ..._buildMaxAndMinDataPoints(),
                    ..._buildCumulativeDataPoints(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
