class DataByDate {
  int healthDataId;
  int injuryId;
  String recordDate;
  String dateCollected;
  num height;
  num weight;
  num bodyMassIndex;
  num bodyFatPercent;
  num waistCircumfrence;
  int restingHeartRate;
  int walkingHeartRate;
  int steps;
  num activeEnergyBurned;
  num basalEnergyBurned;
  int systolicPressureMax;
  int systolicPressureMin;
  int diastolicPressureMax;
  int diastolicPressureMin;
  int heartRateMax;
  int heartRateMin;
  num bodyTemperatureMax;
  num bodyTemperatureMin;
  num bloodOxygenMax;
  num bloodOxygenMin;
  num bloodGlucoseMax;
  num bloodGlucoseMin;
  num lowHeartRateEvent;
  num highHeartRateEvent;
  num irregularHeartRateEvent;
  num electrodermalActivity;
  String createdBy;
  String updatedBy;
  String createDate;
  String updateDate;

  DataByDate(
      {this.healthDataId,
      this.recordDate,
      this.dateCollected,
      this.height,
      this.weight,
      this.bodyMassIndex,
      this.bodyFatPercent,
      this.waistCircumfrence,
      this.restingHeartRate,
      this.walkingHeartRate,
      this.steps,
      this.activeEnergyBurned,
      this.basalEnergyBurned,
      this.systolicPressureMax,
      this.systolicPressureMin,
      this.diastolicPressureMax,
      this.diastolicPressureMin,
      this.heartRateMax,
      this.heartRateMin,
      this.bodyTemperatureMax,
      this.bodyTemperatureMin,
      this.bloodOxygenMax,
      this.bloodOxygenMin,
      this.bloodGlucoseMax,
      this.bloodGlucoseMin,
      this.lowHeartRateEvent,
      this.highHeartRateEvent,
      this.irregularHeartRateEvent,
      this.electrodermalActivity,
      this.createdBy,
      this.createDate,
      this.updatedBy,
      this.updateDate});
}
