import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// A [HealthDataPoint] object corresponds to a data point captures from GoogleFit or Apple HealthKit
class HealthDataPoint extends Equatable {
  final num value;
  final String unit;
  final int dateFrom;
  final int dateTo;
  final String dataType;
  final String platform;

  HealthDataPoint(this.value, this.unit, this.dateFrom, this.dateTo,
      this.dataType, this.platform);

  @override
  List<Object> get props => [value, unit, dateFrom, dateTo, dataType, platform];

  factory HealthDataPoint.fromJson(Map<String, dynamic> json) {
    HealthDataPoint dataPoint;
    try {
      // value = json['value'];
      // unit = json['unit'];
      // dateFrom = json['date_from'];
      // dateTo = json['date_to'];
      // dataType = json['data_type'];
      // platform = json['platform_type'];

      dataPoint = HealthDataPoint(
          json['value'],
          json['unit'],
          json['date_from'],
          json['date_to'],
          json['data_type'],
          json['platform_type']);
    } catch (error) {
      print(error);
    }
    return dataPoint;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['unit'] = this.unit;
    data['date_from'] = this.dateFrom;
    data['date_to'] = this.dateTo;
    data['data_type'] = this.dataType;
    data['platform_type'] = this.platform;
    return data;
  }

  String toString() => '${this.runtimeType} - '
      'value: $value, '
      'unit: $unit, '
      'date_from: ${DateFormat.yMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(dateFrom))}, '
      'dateFrom: $dateFrom, '
      'dateTo: ${DateFormat.yMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(dateTo))}, '
      'dataType: $dataType, '
      'platform: $platform';
}
