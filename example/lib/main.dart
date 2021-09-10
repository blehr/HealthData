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
  List<HealthDataPoint> dataPointsAppleWatch = [];
  List<MaxAndMinHealthDataPoint> dataPointsMaxAndMin = [];
  List<DataByDate> allData = [];
  bool _isAuthorized;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    DateTime now = DateTime.now().add(Duration(days: 1));
    DateTime endDate = DateTime(now.year, now.month, now.day, 0, 0);
    DateTime startDate = endDate.add(Duration(days: -20));

    print("StartDate - ${DateFormat.yMd().add_jm().format(startDate)}");
    print("EndDate - ${DateFormat.yMd().add_jm().format(endDate)}");

    Future.delayed(Duration(seconds: 2), () async {
      _isAuthorized = await HealthData.requestAuthorization();

      if (_isAuthorized) {
        print('Authorized');
      } else {
        return;
      }

      // Platform messages may fail, so we use a try/catch PlatformException.

      // get latest
      try {
        List<HealthDataPoint> weight =
            await HealthData.getDataLatestAvailable(HealthDataType.WEIGHT);
        dataPointsLatest.addAll(weight);
      } catch (e) {
        print(e.toString());
      }

      try {
        List<HealthDataPoint> height =
            await HealthData.getDataLatestAvailable(HealthDataType.HEIGHT);
        dataPointsLatest.addAll(height);
      } catch (e) {
        print(e.toString());
      }

      try {
        List<HealthDataPoint> bodyFat = await HealthData.getDataLatestAvailable(
            HealthDataType.BODY_FAT_PERCENTAGE);
        dataPointsLatest.addAll(bodyFat);
      } catch (e) {
        print(e.toString());
      }

      try {
        List<HealthDataPoint> bmi = await HealthData.getDataLatestAvailable(
            HealthDataType.BODY_MASS_INDEX);
        dataPointsLatest.addAll(bmi);
      } catch (e) {
        print(e.toString());
      }

      if (Platform.isIOS) {
        try {
          List<HealthDataPoint> waistCircumfrence =
              await HealthData.getDataLatestAvailable(
                  HealthDataType.WAIST_CIRCUMFERENCE);
          dataPointsLatest.addAll(waistCircumfrence);
        } catch (e) {
          print(e.toString());
        }

        try {
          List<HealthDataPoint> restingHeartRate =
              await HealthData.getDataLatestAvailable(
                  HealthDataType.RESTING_HEART_RATE);
          dataPointsLatest.addAll(restingHeartRate);
        } catch (e) {
          print(e.toString());
        }

        try {
          List<HealthDataPoint> walkingHeartRate =
              await HealthData.getDataLatestAvailable(
                  HealthDataType.WALKING_HEART_RATE);
          dataPointsLatest.addAll(walkingHeartRate);
        } catch (e) {
          print(e.toString());
        }
      }

      // get cumulative by day

      try {
        List<HealthDataPoint> steps = await HealthData.getDataCumulativeByDay(
            startDate, endDate, HealthDataType.STEPS);
        dataPointsCumulative.addAll(steps);
      } catch (e) {
        print(e.toString());
      }

      try {
        List<HealthDataPoint> activeEnergyBurned =
            await HealthData.getDataCumulativeByDay(
                startDate, endDate, HealthDataType.ACTIVE_ENERGY_BURNED);
        dataPointsCumulative.addAll(activeEnergyBurned);
      } catch (e) {
        print(e.toString());
      }

      if (Platform.isIOS) {
        try {
          List<HealthDataPoint> basalEnergyBurned =
              await HealthData.getDataCumulativeByDay(
                  startDate, endDate, HealthDataType.BASAL_ENERGY_BURNED);

          dataPointsCumulative.addAll(basalEnergyBurned);
        } catch (e) {
          print(e.toString());
        }
      }

      // get max and min by day
      try {
        List<MaxAndMinHealthDataPoint> systolic =
            await HealthData.getMaxAndMinValueForEachDay(
                startDate, endDate, HealthDataType.BLOOD_PRESSURE_SYSTOLIC);
        dataPointsMaxAndMin.addAll(systolic);
      } catch (e) {
        print(e.toString());
      }

      try {
        List<MaxAndMinHealthDataPoint> diastolic =
            await HealthData.getMaxAndMinValueForEachDay(
                startDate, endDate, HealthDataType.BLOOD_PRESSURE_DIASTOLIC);
        dataPointsMaxAndMin.addAll(diastolic);
      } catch (e) {
        print(e.toString());
      }

      try {
        List<MaxAndMinHealthDataPoint> heartRate =
            await HealthData.getMaxAndMinValueForEachDay(
                startDate, endDate, HealthDataType.HEART_RATE);

        dataPointsMaxAndMin.addAll(heartRate);
      } catch (e) {
        print(e.toString());
      }

      try {
        List<MaxAndMinHealthDataPoint> bodyTemperauture =
            await HealthData.getMaxAndMinValueForEachDay(
                startDate, endDate, HealthDataType.BODY_TEMPERATURE);
        dataPointsMaxAndMin.addAll(bodyTemperauture);
      } catch (e) {
        print(e.toString());
      }

      try {
        List<MaxAndMinHealthDataPoint> bloodOxygen =
            await HealthData.getMaxAndMinValueForEachDay(
                startDate, endDate, HealthDataType.BLOOD_OXYGEN);
        dataPointsMaxAndMin.addAll(bloodOxygen);
      } catch (e) {
        print(e.toString());
      }

      try {
        List<MaxAndMinHealthDataPoint> bloodGlucose =
            await HealthData.getMaxAndMinValueForEachDay(
                startDate, endDate, HealthDataType.BLOOD_GLUCOSE);
        dataPointsMaxAndMin.addAll(bloodGlucose);
      } catch (e) {
        print(e.toString());
      }

      // Apple Watch
      if (Platform.isIOS) {
        try {
          List<HealthDataPoint> lowHR =
              await HealthData.getDataByStartAndEndDate(
                  startDate, endDate, HealthDataType.LOW_HEART_RATE_EVENT);
          dataPointsAppleWatch.addAll(lowHR);
        } catch (e) {
          print(e.toString());
        }
        try {
          List<HealthDataPoint> highHR =
              await HealthData.getDataByStartAndEndDate(
                  startDate, endDate, HealthDataType.HIGH_HEART_RATE_EVENT);
          dataPointsAppleWatch.addAll(highHR);
        } catch (e) {
          print(e.toString());
        }
        try {
          List<HealthDataPoint> irregularHR =
              await HealthData.getDataByStartAndEndDate(startDate, endDate,
                  HealthDataType.IRREGULAR_HEART_RATE_EVENT);
          dataPointsAppleWatch.addAll(irregularHR);
        } catch (e) {
          print(e.toString());
        }
        try {
          List<HealthDataPoint> electrodermal =
              await HealthData.getDataByStartAndEndDate(
                  startDate, endDate, HealthDataType.ELECTRODERMAL_ACTIVITY);
          dataPointsAppleWatch.addAll(electrodermal);
        } catch (e) {
          print(e.toString());
        }
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

      mergeItAllTogether();

      setState(() {});
    });
  }

  DataByDate addDataToDay(HealthDataPoint d, DataByDate day) {
    switch (d.dataType) {
      case "HEIGHT":
        day.height = d.value;
        break;
      case "WEIGHT":
        day.weight = d.value;
        break;
      case "BODY_MASS_INDEX":
        day.bodyMassIndex = d.value;
        break;
      case "BODY_FAT_PERCENTAGE":
        day.bodyFatPercent = d.value;
        break;
      case "WAIST_CIRCUMFERENCE":
        day.waistCircumfrence = d.value;
        break;
      case "RESTING_HEART_RATE":
        day.restingHeartRate = d.value;
        break;
      case "WALKING_HEART_RATE":
        day.walkingHeartRate = d.value;
        break;
      case "BASAL_ENERGY_BURNED":
        day.basalEnergyBurned = d.value;
        break;
      case "ACTIVE_ENERGY_BURNED":
        day.activeEnergyBurned = d.value;
        break;
      case "STEPS":
        day.steps = d.value;
        break;
      case "LOW_HEART_RATE_EVENT":
        day.lowHeartRateEvent = d.value;
        break;
      case "HIGH_HEART_RATE_EVENT":
        day.highHeartRateEvent = d.value;
        break;
      case "IRREGULAR_HEART_RATE_EVENT":
        day.irregularHeartRateEvent = d.value;
        break;
      case "ELECTRODERMAL_ACTIVITY":
        day.electrodermalActivity = d.value;
        break;

      default:
        break;
    }

    return day;
  }

  DataByDate addMaxMinDataToDay(MaxAndMinHealthDataPoint d, DataByDate day) {
    switch (d.min.dataType) {
      case "HEART_RATE":
        day.heartRateMax = d.max.value;
        day.heartRateMin = d.min.value;
        break;
      case "BODY_TEMPERATURE":
        day.bodyTemperatureMax = d.max.value;
        day.bodyTemperatureMin = d.min.value;
        break;
      case "BLOOD_OXYGEN":
        day.bloodOxygenMax = d.max.value;
        day.bloodOxygenMin = d.min.value;
        break;
      case "BLOOD_GLUCOSE":
        day.bloodGlucoseMax = d.max.value;
        day.bloodGlucoseMin = d.min.value;
        break;
      case "BLOOD_PRESSURE_SYSTOLIC":
        day.systolicPressureMax = d.max.value;
        day.systolicPressureMin = d.min.value;
        break;
      case "BLOOD_PRESSURE_DIASTOLIC":
        day.diastolicPressureMax = d.max.value;
        day.diastolicPressureMin = d.min.value;
        break;
      default:
    }

    return day;
  }

  mergeItAllTogether() {
    DataByDate latest = DataByDate();
    var today = DateTime.now();
    var todayMDY = DateFormat.yMd().format(today);

    latest.dateCollected = todayMDY;
    latest.recordDate = todayMDY;

    // handleLatestData
    dataPointsLatest.forEach((d) {
      addDataToDay(d, latest);
    });

    // add latest to allData
    allData.add(latest);

    // handle cumulative data
    dataPointsCumulative.forEach((d) {
      // is there a dataByDay with same date?
      var dDate = DateFormat.yMd()
          .format(DateTime.fromMillisecondsSinceEpoch(d.dateFrom));
      var sameDay = allData.firstWhere((dbd) => dbd.recordDate == dDate,
          orElse: () => null);

      if (sameDay != null) {
        addDataToDay(d, sameDay);
      } else {
        DataByDate newDay = DataByDate();
        newDay.dateCollected = todayMDY;
        newDay.recordDate = dDate;

        var filledDataByDay = addDataToDay(d, newDay);
        allData.add(filledDataByDay);
      }
    });

    // handle max min data

    dataPointsMaxAndMin.forEach((d) {
      // is there a dataByDay with same date?
      var dDate = DateFormat.yMd()
          .format(DateTime.fromMillisecondsSinceEpoch(d.min.dateFrom));
      var sameDay = allData.firstWhere((dbd) => dbd.recordDate == dDate,
          orElse: () => null);

      if (sameDay != null) {
        addMaxMinDataToDay(d, sameDay);
      } else {
        DataByDate newDay = DataByDate();
        newDay.dateCollected = todayMDY;
        newDay.recordDate = dDate;

        var filledDataByDay = addMaxMinDataToDay(d, newDay);
        allData.add(filledDataByDay);
      }
    });

    // apple watch
    dataPointsAppleWatch.forEach((d) {
      // is there a dataByDay with same date?
      var dDate = DateFormat.yMd()
          .format(DateTime.fromMillisecondsSinceEpoch(d.dateFrom));
      var sameDay = allData.firstWhere((dbd) => dbd.recordDate == dDate,
          orElse: () => null);

      if (sameDay != null) {
        addDataToDay(d, sameDay);
      } else {
        DataByDate newDay = DataByDate();
        newDay.dateCollected = todayMDY;
        newDay.recordDate = dDate;

        var filledDataByDay = addDataToDay(d, newDay);
        allData.add(filledDataByDay);
      }
    });

    allData.sort((a, b) => DateFormat("M/d/yyyy")
        .parse(b.recordDate)
        .compareTo(DateFormat("M/d/yyyy").parse(a.recordDate)));

    setState(() {
      allData = allData;
    });
  }

  String getValuesFixed(num value) {
    if (value == null) {
      return "";
    }
    return value.toStringAsFixed(2);
  }

  List<DataRow> _buildAllData() {
    if (allData.isEmpty) {
      return [];
    }
    return allData
        .map(
          (d) => DataRow(
            cells: [
              DataCell(Text(d.recordDate)),
              DataCell(Text(getValuesFixed(d.height))),
              DataCell(Text(getValuesFixed(d.weight))),
              DataCell(Text(getValuesFixed(d.bodyMassIndex))),
              DataCell(Text(getValuesFixed(d.bodyFatPercent))),
              DataCell(Text(getValuesFixed(d.waistCircumfrence))),
              DataCell(Text(getValuesFixed(d.steps))),
              DataCell(Text(getValuesFixed(d.restingHeartRate))),
              DataCell(Text(getValuesFixed(d.walkingHeartRate))),
              DataCell(Text(getValuesFixed(d.heartRateMin))),
              DataCell(Text(getValuesFixed(d.heartRateMax))),
              DataCell(Text(getValuesFixed(d.activeEnergyBurned))),
              DataCell(Text(getValuesFixed(d.basalEnergyBurned))),
              DataCell(Text(getValuesFixed(d.systolicPressureMin))),
              DataCell(Text(getValuesFixed(d.systolicPressureMax))),
              DataCell(Text(getValuesFixed(d.diastolicPressureMin))),
              DataCell(Text(getValuesFixed(d.diastolicPressureMax))),
              DataCell(Text(getValuesFixed(d.bodyTemperatureMin))),
              DataCell(Text(getValuesFixed(d.bodyTemperatureMax))),
              DataCell(Text(getValuesFixed(d.bloodGlucoseMin))),
              DataCell(Text(getValuesFixed(d.bloodGlucoseMax))),
              DataCell(Text(getValuesFixed(d.bloodOxygenMin))),
              DataCell(Text(getValuesFixed(d.bloodOxygenMax))),
              DataCell(Text(getValuesFixed(d.lowHeartRateEvent))),
              DataCell(Text(getValuesFixed(d.highHeartRateEvent))),
              DataCell(Text(getValuesFixed(d.irregularHeartRateEvent))),
              DataCell(Text(getValuesFixed(d.electrodermalActivity))),
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
                    DataColumn(label: Text("Height")),
                    DataColumn(label: Text("Weight")),
                    DataColumn(label: Text("BMI")),
                    DataColumn(label: Text("BodyFat%")),
                    DataColumn(label: Text("Waist Circ")),
                    DataColumn(label: Text("Steps")),
                    DataColumn(label: Text("Resting HeartRate")),
                    DataColumn(label: Text("Walking HeartRate")),
                    DataColumn(label: Text("Min HeartRate")),
                    DataColumn(label: Text("Max HeartRate")),
                    DataColumn(label: Text("Active Energy")),
                    DataColumn(label: Text("Basal Energy")),
                    DataColumn(label: Text("Min Systolic")),
                    DataColumn(label: Text("Max Systolic")),
                    DataColumn(label: Text("Min Diastolic")),
                    DataColumn(label: Text("Max Diastolic")),
                    DataColumn(label: Text("Min BodyTemp")),
                    DataColumn(label: Text("Max BodyTemp")),
                    DataColumn(label: Text("Min Blood Glucose")),
                    DataColumn(label: Text("Max Blood Glucose")),
                    DataColumn(label: Text("Min Blood Oxygen")),
                    DataColumn(label: Text("Max Blood Oxygen")),
                    DataColumn(label: Text("Low HeartRate Event")),
                    DataColumn(label: Text("High HeartRate Event")),
                    DataColumn(label: Text("Irregular HeartRate Event")),
                    DataColumn(label: Text("Electrodermal Activity")),
                  ],
                  rows: [
                    ..._buildAllData(),
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
