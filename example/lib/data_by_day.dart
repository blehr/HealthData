class DataByDay {
  int healthDataId;
  DateTime dayOfRow;
  DateTime dayCollected;
  num height;
  num weight;
  num bodyMassIndex;
  num bodyFatPercent;
  num waistCircumfrence;
  num restingHeartRate;
  num walkingHeartRate;
  num totalSteps;
  num totalActiveEnergyBurned;
  num totalBasalEnergyBurned;
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
  String createdBy;
  String updatedBy;
  String createDate;
  String updateDate;

  DataByDay({
    this.healthDataId,
    this.dayOfRow,
    this.dayCollected,
    this.height,
    this.weight,
    this.bodyMassIndex,
    this.bodyFatPercent,
    this.waistCircumfrence,
    this.restingHeartRate,
    this.walkingHeartRate,
    this.totalSteps,
    this.totalActiveEnergyBurned,
    this.totalBasalEnergyBurned,
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
    this.createdBy,
    this.createDate,
    this.updatedBy,
    this.updateDate
  });

}