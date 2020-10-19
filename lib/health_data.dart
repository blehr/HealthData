import 'dart:async';
import 'package:flutter/services.dart';
import 'package:health_data/health_data_point.dart';
import 'dart:io' show Platform;

import 'package:intl/intl.dart';

class HealthDataNotAvailableException implements Exception {
  HealthDataType _dataType;
  PlatformType _platformType;

  HealthDataNotAvailableException(this._dataType, this._platformType);

  String toString() {
    return "Method ${_dataType.toString()} not implemented for platform ${_platformType.toString()}";
  }
}

class MaxAndMinHealthDataPoint {
  String date;
  HealthDataPoint min;
  HealthDataPoint max;

  MaxAndMinHealthDataPoint(this.date, this.max, this.min);

  String toString() => '${this.runtimeType} - '
      'date: $date, '
      'min: $min, '
      'max: $max, ';
}

/// Extracts the string value from an enum
String enumToString(enumItem) => enumItem.toString().split('.')[1];

/// List of all units.
enum HealthDataUnit {
  KILOGRAMS,
  PERCENTAGE,
  METERS,
  COUNT,
  BEATS_PER_MINUTE,
  CALORIES,
  DEGREE_CELSIUS,
  NO_UNIT,
  SIEMENS,
  MILLIMETER_OF_MERCURY,
  MILLIGRAM_PER_DECILITER
}

/// List of all available data types.
enum HealthDataType {
  BODY_FAT_PERCENTAGE,
  HEIGHT,
  WEIGHT,
  BODY_MASS_INDEX,
  WAIST_CIRCUMFERENCE,
  STEPS,
  BASAL_ENERGY_BURNED,
  ACTIVE_ENERGY_BURNED,
  HEART_RATE,
  BODY_TEMPERATURE,
  BLOOD_PRESSURE_SYSTOLIC,
  BLOOD_PRESSURE_DIASTOLIC,
  RESTING_HEART_RATE,
  WALKING_HEART_RATE,
  BLOOD_OXYGEN,
  BLOOD_GLUCOSE,
  ELECTRODERMAL_ACTIVITY,

  // Heart Rate events (specific to Apple Watch)
  HIGH_HEART_RATE_EVENT,
  LOW_HEART_RATE_EVENT,
  IRREGULAR_HEART_RATE_EVENT
}

/// Map a [HealthDataType] to a [HealthDataUnit].
const Map<HealthDataType, HealthDataUnit> _dataTypeToUnit = {
  HealthDataType.BODY_FAT_PERCENTAGE: HealthDataUnit.PERCENTAGE,
  HealthDataType.HEIGHT: HealthDataUnit.METERS,
  HealthDataType.WEIGHT: HealthDataUnit.KILOGRAMS,
  HealthDataType.BODY_MASS_INDEX: HealthDataUnit.NO_UNIT,
  HealthDataType.WAIST_CIRCUMFERENCE: HealthDataUnit.METERS,
  HealthDataType.STEPS: HealthDataUnit.COUNT,
  HealthDataType.BASAL_ENERGY_BURNED: HealthDataUnit.CALORIES,
  HealthDataType.ACTIVE_ENERGY_BURNED: HealthDataUnit.CALORIES,
  HealthDataType.HEART_RATE: HealthDataUnit.BEATS_PER_MINUTE,
  HealthDataType.BODY_TEMPERATURE: HealthDataUnit.DEGREE_CELSIUS,
  HealthDataType.BLOOD_PRESSURE_SYSTOLIC: HealthDataUnit.MILLIMETER_OF_MERCURY,
  HealthDataType.BLOOD_PRESSURE_DIASTOLIC: HealthDataUnit.MILLIMETER_OF_MERCURY,
  HealthDataType.RESTING_HEART_RATE: HealthDataUnit.BEATS_PER_MINUTE,
  HealthDataType.WALKING_HEART_RATE: HealthDataUnit.BEATS_PER_MINUTE,
  HealthDataType.BLOOD_OXYGEN: HealthDataUnit.PERCENTAGE,
  HealthDataType.BLOOD_GLUCOSE: HealthDataUnit.MILLIGRAM_PER_DECILITER,
  HealthDataType.ELECTRODERMAL_ACTIVITY: HealthDataUnit.SIEMENS,

  /// Heart Rate events (specific to Apple Watch)
  HealthDataType.HIGH_HEART_RATE_EVENT: HealthDataUnit.NO_UNIT,
  HealthDataType.LOW_HEART_RATE_EVENT: HealthDataUnit.NO_UNIT,
  HealthDataType.IRREGULAR_HEART_RATE_EVENT: HealthDataUnit.NO_UNIT
};

/// List of data types available on iOS
const List<HealthDataType> _dataTypesIOS = [
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

/// List of data types available on Android
const List<HealthDataType> _dataTypesAndroid = [
  HealthDataType.BODY_FAT_PERCENTAGE,
  HealthDataType.HEIGHT,
  HealthDataType.WEIGHT,
  HealthDataType.BODY_MASS_INDEX,
  HealthDataType.STEPS,
  HealthDataType.ACTIVE_ENERGY_BURNED,
  HealthDataType.HEART_RATE,
  HealthDataType.BODY_TEMPERATURE,
  HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
  HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
  HealthDataType.BLOOD_OXYGEN,
  HealthDataType.BLOOD_GLUCOSE,
];

enum PlatformType { IOS, ANDROID }

class HealthData {
  static const MethodChannel _channel = const MethodChannel('health_data');
  static PlatformType _platformType =
      Platform.isAndroid ? PlatformType.ANDROID : PlatformType.IOS;

  /// Check if a given data type is available on the platform
  static bool isDataTypeAvailable(HealthDataType dataType) =>
      _platformType == PlatformType.ANDROID
          ? _dataTypesAndroid.contains(dataType)
          : _dataTypesIOS.contains(dataType);

  // Request access to GoogleFit/Apple HealthKit
  static Future<bool> requestAuthorization() async {
    final bool isAuthorized =
        await _channel.invokeMethod('requestAuthorization');
    return isAuthorized;
  }

  static HealthDataPoint processDataPoint(
      var dataPoint, HealthDataType dataType, HealthDataUnit unit) {
    // Set the platform_type and data_type fields
    dataPoint["platform_type"] = _platformType.toString();

    // Set the [DataType] fields
    dataPoint["data_type"] = enumToString(dataType);

    // Overwrite unit with a Flutter Unit
    dataPoint["unit"] = enumToString(unit);

    // Convert to JSON, and then to HealthData object
    return HealthDataPoint.fromJson(Map<String, dynamic>.from(dataPoint));
  }

  // Calculate the BMI using the last observed height and weight values.
  static Future<List<HealthDataPoint>> _androidBodyMassIndex() async {
    List<HealthDataPoint> heights =
        await getDataLatestAvailable(HealthDataType.HEIGHT);
    List<HealthDataPoint> weights =
        await getDataLatestAvailable(HealthDataType.WEIGHT);

    num bmiValue =
        weights.last.value / (heights.last.value * heights.last.value);

    HealthDataType dataType = HealthDataType.BODY_MASS_INDEX;
    HealthDataUnit unit = _dataTypeToUnit[dataType];

    HealthDataPoint bmi = HealthDataPoint(
        bmiValue,
        enumToString(unit),
        DateTime.now().millisecondsSinceEpoch,
        DateTime.now().millisecondsSinceEpoch,
        enumToString(dataType),
        PlatformType.ANDROID.toString());

    return [bmi];
  }

  static Future<List<HealthDataPoint>> getDataByStartAndEndDate(
      DateTime startDate, DateTime endDate, HealthDataType dataType) async {
    // If not implemented on platform, throw an exception
    if (!isDataTypeAvailable(dataType)) {
      throw new HealthDataNotAvailableException(dataType, _platformType);
    }

    // Set parameters for method channel request
    Map<String, dynamic> args = {
      'dataTypeKey': enumToString(dataType),
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch
    };

    List<HealthDataPoint> healthData = new List();
    HealthDataUnit unit = _dataTypeToUnit[dataType];

    try {
      List fetchedDataPoints =
          await _channel.invokeMethod('getDataByStartAndEndDate', args);

      /// Process each data point received
      for (var dataPoint in fetchedDataPoints) {
        HealthDataPoint data = processDataPoint(dataPoint, dataType, unit);
        healthData.add(data);
      }
    } catch (error) {
      print(error);
    }
    return healthData;
  }

  static Future<List<HealthDataPoint>> getDataCumulativeByDay(
      DateTime startDate, DateTime endDate, HealthDataType dataType) async {
    // If not implemented on platform, throw an exception
    if (!isDataTypeAvailable(dataType)) {
      throw new HealthDataNotAvailableException(dataType, _platformType);
    }

    // Set parameters for method channel request
    Map<String, dynamic> args = {
      'dataTypeKey': enumToString(dataType),
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch
    };

    List<HealthDataPoint> healthData = new List();
    HealthDataUnit unit = _dataTypeToUnit[dataType];

    try {
      List fetchedDataPoints =
          await _channel.invokeMethod('getDataCumulativeByDay', args);

      /// Process each data point received
      for (var dataPoint in fetchedDataPoints) {
        HealthDataPoint data = processDataPoint(dataPoint, dataType, unit);
        healthData.add(data);
      }
    } catch (error) {
      print(error);
    }
    return healthData;
  }

  static Future<List<HealthDataPoint>> getDataAverageByWeek(
      DateTime startDate, DateTime endDate, HealthDataType dataType) async {
    // If not implemented on platform, throw an exception
    if (!isDataTypeAvailable(dataType)) {
      throw new HealthDataNotAvailableException(dataType, _platformType);
    }

    // Set parameters for method channel request
    Map<String, dynamic> args = {
      'dataTypeKey': enumToString(dataType),
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch
    };

    List<HealthDataPoint> healthData = new List();
    HealthDataUnit unit = _dataTypeToUnit[dataType];

    try {
      List fetchedDataPoints =
          await _channel.invokeMethod('getDataAverageByWeek', args);

      /// Process each data point received
      for (var dataPoint in fetchedDataPoints) {
        HealthDataPoint data = processDataPoint(dataPoint, dataType, unit);
        healthData.add(data);
      }
    } catch (error) {
      print(error);
    }
    return healthData;
  }

  static Future<List<HealthDataPoint>> getDataLatestAvailable(
      HealthDataType dataType) async {
    // If not implemented on platform, throw an exception
    if (!isDataTypeAvailable(dataType)) {
      throw new HealthDataNotAvailableException(dataType, _platformType);
    }

    // If BodyMassIndex is requested on Android, calculate this manually in Dart
    else if (dataType == HealthDataType.BODY_MASS_INDEX &&
        _platformType == PlatformType.ANDROID) {
      return _androidBodyMassIndex();
    }

    // Set parameters for method channel request
    Map<String, dynamic> args = {
      'dataTypeKey': enumToString(dataType),
      'startDate': 0,
      'endDate': 0
    };

    List<HealthDataPoint> healthData = new List();
    HealthDataUnit unit = _dataTypeToUnit[dataType];

    try {
      List fetchedDataPoints =
          await _channel.invokeMethod('getDataLatestAvailable', args);

      /// Process each data point received
      for (var dataPoint in fetchedDataPoints) {
        HealthDataPoint data = processDataPoint(dataPoint, dataType, unit);
        healthData.add(data);
      }
    } catch (error) {
      print(error);
    }
    return healthData;
  }

  static bool isSameDay(DateTime curr, DateTime compare) {
    if (curr.month == compare.month &&
        curr.day == compare.day &&
        curr.year == compare.year) {
      return true;
    }
    return false;
  }

  static Future<List<MaxAndMinHealthDataPoint>> getMaxAndMinValueForEachDay(
      DateTime startDate, DateTime endDate, HealthDataType dataType) async {
    List<MaxAndMinHealthDataPoint> dataPoints = [];

    try {
      List<HealthDataPoint> list =
          await getDataByStartAndEndDate(startDate, endDate, dataType);

      List<Map<String, dynamic>> groups = groupByDay(list);

      groups.forEach((m) {
        List<HealthDataPoint> data = m["data"].cast<HealthDataPoint>();
        data.sort((a, b) => a.value.compareTo(b.value));

        dataPoints
            .add(MaxAndMinHealthDataPoint(m["date"], data.last, data.first));
      });
    } catch (e) {
      print("GET MAX AND MIN EXCEPTION FROM HEALTH DATA");
      print(e.toString());
    }

    return dataPoints;
  }

  static List<Map<String, dynamic>> groupByDay(List<HealthDataPoint> list) {
    List<Map<String, dynamic>> listOfMapByDay = [];
    List<HealthDataPoint> temp = [];
    DateTime currentDate;

    list.forEach((d) {
      // at first currentDate will be null
      if (currentDate != null) {
        // if d.dateFrom is not same day as currentDate
        if (isSameDay(
            currentDate, DateTime.fromMillisecondsSinceEpoch(d.dateFrom))) {
          temp.add(d);
        } else {
          listOfMapByDay.add({
            "date": DateFormat.yMd().format(currentDate),
            "data": List.from(temp),
          });
          temp.clear();
        }
      }

      // if temp isEmpty set the date and add d
      if (temp.isEmpty) {
        currentDate = DateTime.fromMillisecondsSinceEpoch(d.dateFrom);
        temp.add(d);
      }

      // if this is the last item
      if (list.indexOf(d) == list.length - 1) {
        listOfMapByDay.add({
          "date": DateFormat.yMd().format(currentDate),
          "data": List.from(temp),
        });
      }
    });

    return listOfMapByDay;
  }

  static num convertKilogramsToPounds(num kValue) {
    return kValue * 2.20462;
  }

  static num convertMetersToInches(num mValue) {
    return mValue * 39.3701;
  }

  static num convertCelsiusToFahrenheit(num cValue) {
    return (cValue * 1.8) + 32;
  }
}
