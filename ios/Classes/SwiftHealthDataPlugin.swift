import Flutter
import UIKit
import HealthKit

public class SwiftHealthDataPlugin: NSObject, FlutterPlugin {
    
    let healthStore = HKHealthStore()
    var healthDataTypes = [HKObjectType]()
    var heartRateEventTypes = Set<HKObjectType>()
    var allDataTypes = Set<HKObjectType>()
    var dataTypesDict: [String: HKObjectType] = [:]
    var unitDict: [String: HKUnit] = [:]
    
    // Health Data Type Keys
    let BODY_FAT_PERCENTAGE = "BODY_FAT_PERCENTAGE"
    let HEIGHT = "HEIGHT"
    let WEIGHT = "WEIGHT"
    let BODY_MASS_INDEX = "BODY_MASS_INDEX"
    let WAIST_CIRCUMFERENCE = "WAIST_CIRCUMFERENCE"
    let STEPS = "STEPS"
    let BASAL_ENERGY_BURNED = "BASAL_ENERGY_BURNED"
    let ACTIVE_ENERGY_BURNED = "ACTIVE_ENERGY_BURNED"
    let HEART_RATE = "HEART_RATE"
    let BODY_TEMPERATURE = "BODY_TEMPERATURE"
    let BLOOD_PRESSURE_SYSTOLIC = "BLOOD_PRESSURE_SYSTOLIC"
    let BLOOD_PRESSURE_DIASTOLIC = "BLOOD_PRESSURE_DIASTOLIC"
    let RESTING_HEART_RATE = "RESTING_HEART_RATE"
    let WALKING_HEART_RATE = "WALKING_HEART_RATE"
    let BLOOD_OXYGEN = "BLOOD_OXYGEN"
    let BLOOD_GLUCOSE = "BLOOD_GLUCOSE"
    let ELECTRODERMAL_ACTIVITY = "ELECTRODERMAL_ACTIVITY"
    let HIGH_HEART_RATE_EVENT = "HIGH_HEART_RATE_EVENT"
    let LOW_HEART_RATE_EVENT = "LOW_HEART_RATE_EVENT"
    let IRREGULAR_HEART_RATE_EVENT = "IRREGULAR_HEART_RATE_EVENT"
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "health_data", binaryMessenger: registrar.messenger())
        let instance = SwiftHealthDataPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Set up all data types
        initializeTypes()
        
        if (call.method.elementsEqual("isHealthDataAvailable")) {
            isHealthDataAvailable(call: call, result: result)
        } else if (call.method.elementsEqual("requestAuthorization")) {
            requestAuthorization(call: call, result: result)
        } else if (call.method.elementsEqual("getDataByStartAndEndDate")) {
            getDataByStartAndEndDate(call: call, result: result)
        } else if (call.method.elementsEqual("getDataCumulativeByDay")) {
            getDataCumulativeByDay(call: call, result: result)
        } else if (call.method.elementsEqual("getDataLatestAvailable")) {
            getDataLatestAvailable(call: call, result: result)
        } else if (call.method.elementsEqual("getDataAveragedByDay")) {
            getDataAveragedByDay(call: call, result: result)
        }
        else {
            result("iOS " + UIDevice.current.systemVersion)
        }
        
        
    }
    
    func getDataLatestAvailable(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let dataTypeKey = (arguments?["dataTypeKey"] as? String) ?? "DEFAULT"
        
        let dataType = dataTypeLookUp(key: dataTypeKey)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        var toSend = [Dictionary<String, Any>]()
        
        let query = HKSampleQuery(sampleType: dataType as! HKSampleType, predicate: nil, limit: 1, sortDescriptors: [sort]) { (query, results, error) in
            if let resultNeeded = results?.first as? HKQuantitySample{
                let unit = self.unitLookUp(key: dataTypeKey)
                print("Height => \(resultNeeded.quantity.doubleValue(for: unit))")
                
                
                toSend.append([
                    "value": resultNeeded.quantity.doubleValue(for: unit),
                    "date_from": Int(resultNeeded.startDate.timeIntervalSince1970 * 1000),
                    "date_to": Int(resultNeeded.endDate.timeIntervalSince1970 * 1000),
                ])
                result(toSend)
            }else{
                result(FlutterError(code: "HealthData", message: "Results are null", details: error))
            }
        }
        healthStore.execute(query)
    }
    
    func getDataCumulativeByDay(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let dataTypeKey = (arguments?["dataTypeKey"] as? String) ?? "DEFAULT"
        let startDate = (arguments?["startDate"] as? NSNumber) ?? 0
        let endDate = (arguments?["endDate"] as? NSNumber) ?? 0
        
        let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)
        
        let dataType = dataTypeLookUp(key: dataTypeKey)
        let unit = unitLookUp(key: dataTypeKey)
        
        let calendar = Calendar.current
        
        var interval = DateComponents()
        interval.day = 1
        
        var anchorComponents = calendar.dateComponents([.day, .month, .year], from: Date())
        
        anchorComponents.hour = 0
        
        guard let anchorDate = calendar.date(from: anchorComponents) else {
            return
        }
        
        let query = HKStatisticsCollectionQuery(quantityType: dataType as! HKQuantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval as DateComponents)
        
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                result(FlutterError(code: "HealthData", message: "Results are null", details: error))
                return
            }
            
            
            var toSend = [Dictionary<String, Any>]()
            
            statsCollection.enumerateStatistics(from: dateFrom, to: dateTo) { statistics, stop in
                if let quantity = statistics.sumQuantity() {
                    let date = Int(statistics.startDate.timeIntervalSince1970 * 1000)
                    print(date)
                    let value = quantity.doubleValue(for: unit)
                    
                    toSend.append([
                        "value": value,
                        "date_from": date,
                        "date_to": date
                    ])
                }
            }
            
            result(toSend)
            return
        }
        healthStore.execute(query)
    }
    
    func getDataAveragedByDay(call: FlutterMethodCall, result: @escaping FlutterResult) {
           let arguments = call.arguments as? NSDictionary
           let dataTypeKey = (arguments?["dataTypeKey"] as? String) ?? "DEFAULT"
           let startDate = (arguments?["startDate"] as? NSNumber) ?? 0
           let endDate = (arguments?["endDate"] as? NSNumber) ?? 0
           
           let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
           let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)
           
           let dataType = dataTypeLookUp(key: dataTypeKey)
            let unit = unitLookUp(key: dataTypeKey)
           
           let calendar = Calendar.current
           
           var interval = DateComponents()
           interval.day = 1
           
           var anchorComponents = calendar.dateComponents([.day, .month, .year], from: Date())
           
           anchorComponents.hour = 0
           
           guard let anchorDate = calendar.date(from: anchorComponents) else {
               return
           }
           
           let query = HKStatisticsCollectionQuery(quantityType: dataType as! HKQuantityType,
                                                   quantitySamplePredicate: nil,
                                                   options: .discreteAverage,
                                                   anchorDate: anchorDate,
                                                   intervalComponents: interval as DateComponents)
           
           query.initialResultsHandler = {
               query, results, error in
               
               guard let statsCollection = results else {
                   result(FlutterError(code: "HealthData", message: "Results are null", details: error))
                   return
               }
               
               
               var toSend = [Dictionary<String, Any>]()
               
               statsCollection.enumerateStatistics(from: dateFrom, to: dateTo) { statistics, stop in
                if let quantity = statistics.averageQuantity() {
                       let date = Int(statistics.startDate.timeIntervalSince1970 * 1000)
                       print(date)
                       let value = quantity.doubleValue(for: unit)
                       
                       toSend.append([
                           "value": value,
                           "date_from": date,
                           "date_to": date
                       ])
                   }
               }
               
               result(toSend)
               return
           }
           healthStore.execute(query)
       }
    
    
    
    func getDataByStartAndEndDate(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        let dataTypeKey = (arguments?["dataTypeKey"] as? String) ?? "DEFAULT"
        let startDate = (arguments?["startDate"] as? NSNumber) ?? 0
        let endDate = (arguments?["endDate"] as? NSNumber) ?? 0
        
        // Convert dates from milliseconds to Date()
        let dateFrom = Date(timeIntervalSince1970: startDate.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: endDate.doubleValue / 1000)
        
        let dataType = dataTypeLookUp(key: dataTypeKey)
        let predicate = HKQuery.predicateForSamples(withStart: dateFrom, end: dateTo, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: dataType as! HKSampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {
            x, samplesOrNil, error in
            
            guard let samples = samplesOrNil as? [HKQuantitySample] else {
                result(FlutterError(code: "HealthData", message: "Results are null", details: error))
                return
            }
            
            result(samples.map { sample -> NSDictionary in
                let unit = self.unitLookUp(key: dataTypeKey)
                
                return [
                    "value": sample.quantity.doubleValue(for: unit),
                    "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                    "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                ]
            })
            
            return
        }
        HKHealthStore().execute(query)
    }
    
    func isHealthDataAvailable(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(HKHealthStore.isHealthDataAvailable())
    }
    
    func requestAuthorization(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 11.0, *) {
            healthStore.requestAuthorization(toShare: nil, read: allDataTypes) { (success, error) in
                result(success)
            }
        }
        else {
            result(false)
        }
    }
    
    func unitLookUp(key: String) -> HKUnit {
        guard let unit = unitDict[key] else {
            return HKUnit.count()
        }
        return unit
    }
    
    func dataTypeLookUp(key: String) -> HKObjectType {
        guard let dataType_ = dataTypesDict[key] else {
            return HKObjectType.quantityType(forIdentifier: .bodyMass)!
        }
        return dataType_
    }
    
    func initializeTypes() {
        unitDict[BODY_FAT_PERCENTAGE] = HKUnit.percent()
        unitDict[HEIGHT] = HKUnit.meter()
        unitDict[BODY_MASS_INDEX] = HKUnit.init(from: "")
        unitDict[WAIST_CIRCUMFERENCE] = HKUnit.meter()
        unitDict[STEPS] = HKUnit.count()
        unitDict[BASAL_ENERGY_BURNED] = HKUnit.kilocalorie()
        unitDict[ACTIVE_ENERGY_BURNED] = HKUnit.kilocalorie()
        unitDict[HEART_RATE] = HKUnit.init(from: "count/min")
        unitDict[BODY_TEMPERATURE] = HKUnit.degreeCelsius()
        unitDict[BLOOD_PRESSURE_SYSTOLIC] = HKUnit.millimeterOfMercury()
        unitDict[BLOOD_PRESSURE_DIASTOLIC] = HKUnit.millimeterOfMercury()
        unitDict[RESTING_HEART_RATE] = HKUnit.init(from: "count/min")
        unitDict[WALKING_HEART_RATE] = HKUnit.init(from: "count/min")
        unitDict[BLOOD_OXYGEN] = HKUnit.percent()
        unitDict[BLOOD_GLUCOSE] = HKUnit.init(from: "mg/dl")
        unitDict[ELECTRODERMAL_ACTIVITY] = HKUnit.siemen()
        unitDict[WEIGHT] = HKUnit.gramUnit(with: .kilo)

        
        // Set up iOS 11 specific types (ordinary health data types)
        if #available(iOS 11.0, *) {
            dataTypesDict[BODY_FAT_PERCENTAGE] = HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!
            dataTypesDict[HEIGHT] = HKObjectType.quantityType(forIdentifier: .height)!
            dataTypesDict[BODY_MASS_INDEX] = HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!
            dataTypesDict[WAIST_CIRCUMFERENCE] = HKObjectType.quantityType(forIdentifier: .waistCircumference)!
            dataTypesDict[STEPS] = HKObjectType.quantityType(forIdentifier: .stepCount)!
            dataTypesDict[BASAL_ENERGY_BURNED] = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!
            dataTypesDict[ACTIVE_ENERGY_BURNED] = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
            dataTypesDict[HEART_RATE] = HKObjectType.quantityType(forIdentifier: .heartRate)!
            dataTypesDict[BODY_TEMPERATURE] = HKObjectType.quantityType(forIdentifier: .bodyTemperature)!
            dataTypesDict[BLOOD_PRESSURE_SYSTOLIC] = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!
            dataTypesDict[BLOOD_PRESSURE_DIASTOLIC] = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!
            dataTypesDict[RESTING_HEART_RATE] = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
            dataTypesDict[WALKING_HEART_RATE] = HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!
            dataTypesDict[BLOOD_OXYGEN] = HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!
            dataTypesDict[BLOOD_GLUCOSE] = HKObjectType.quantityType(forIdentifier: .bloodGlucose)!
            dataTypesDict[ELECTRODERMAL_ACTIVITY] = HKObjectType.quantityType(forIdentifier: .electrodermalActivity)!
            dataTypesDict[WEIGHT] = HKObjectType.quantityType(forIdentifier: .bodyMass)!
            
            healthDataTypes = Array(dataTypesDict.values)
        }
        // Set up heart rate data types specific to the apple watch, requires iOS 12
        if #available(iOS 12.2, *){
            dataTypesDict[HIGH_HEART_RATE_EVENT] = HKObjectType.categoryType(forIdentifier: .highHeartRateEvent)!
            dataTypesDict[LOW_HEART_RATE_EVENT] = HKObjectType.categoryType(forIdentifier: .lowHeartRateEvent)!
            dataTypesDict[IRREGULAR_HEART_RATE_EVENT] = HKObjectType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!
            
            heartRateEventTypes =  Set([
                HKObjectType.categoryType(forIdentifier: .highHeartRateEvent)!,
                HKObjectType.categoryType(forIdentifier: .lowHeartRateEvent)!,
                HKObjectType.categoryType(forIdentifier: .irregularHeartRhythmEvent)!,
            ])
        }
        
        // Concatenate heart events and health data types (both may be empty)
        allDataTypes = Set(heartRateEventTypes + healthDataTypes)
    }
    
}
