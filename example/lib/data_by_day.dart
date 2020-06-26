class DataByDay {
  int healthDataId;
  String dateOfData;
  String dateCollected;
  num height;
  num weight;
  num bodyMassIndex;
  num bodyFatPercent;
  num waistCircumfrence;
  num restingHeartRate;
  num walkingHeartRate;
  num steps;
  num activeEnergyBurned;
  num basalEnergyBurned;
  num systolicPressureMax;
  num systolicPressureMin;
  num diastolicPressureMax;
  num diastolicPressureMin;
  num heartRateMax;
  num heartRateMin;
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

  DataByDay(
      {this.healthDataId,
      this.dateOfData,
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
