package com.brandonlehr.health_data

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.fitness.Fitness
import com.google.android.gms.fitness.FitnessOptions
import com.google.android.gms.fitness.data.*
import com.google.android.gms.fitness.request.DataReadRequest
import com.google.android.gms.fitness.result.DataReadResponse
import com.google.android.gms.tasks.Tasks
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.collections.HashMap
import kotlin.concurrent.thread

const val GOOGLE_FIT_PERMISSIONS_REQUEST_CODE = 1212

/** HealthDataPlugin */
public class HealthDataPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener, Result {


  private lateinit var channel : MethodChannel
  // private var context: Context? = null
  // private var activity: Activity? = null

  private lateinit var context: Context
  private lateinit var activity: Activity


  private var result: Result? = null
  private var handler: Handler? = null

  private var BODY_FAT_PERCENTAGE = "BODY_FAT_PERCENTAGE"
  private var HEIGHT = "HEIGHT"
  private var WEIGHT = "WEIGHT"
  private var BODY_MASS_INDEX = "BODY_MASS_INDEX"
  private var WAIST_CIRCUMFERENCE = "WAIST_CIRCUMFERENCE"
  private var STEPS = "STEPS"
  private var BASAL_ENERGY_BURNED = "BASAL_ENERGY_BURNED"
  private var ACTIVE_ENERGY_BURNED = "ACTIVE_ENERGY_BURNED"
  private var HEART_RATE = "HEART_RATE"
  private var BODY_TEMPERATURE = "BODY_TEMPERATURE"
  private var BLOOD_PRESSURE_SYSTOLIC = "BLOOD_PRESSURE_SYSTOLIC"
  private var BLOOD_PRESSURE_DIASTOLIC = "BLOOD_PRESSURE_DIASTOLIC"
  private var RESTING_HEART_RATE = "RESTING_HEART_RATE"
  private var WALKING_HEART_RATE = "WALKING_HEART_RATE"
  private var BLOOD_OXYGEN = "BLOOD_OXYGEN"
  private var BLOOD_GLUCOSE = "BLOOD_GLUCOSE"
  private var ELECTRODERMAL_ACTIVITY = "ELECTRODERMAL_ACTIVITY"
  private var HIGH_HEART_RATE_EVENT = "HIGH_HEART_RATE_EVENT"
  private var LOW_HEART_RATE_EVENT = "LOW_HEART_RATE_EVENT"
  private var IRREGULAR_HEART_RATE_EVENT = "IRREGULAR_HEART_RATE_EVENT"



  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "health_data")
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.applicationContext
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "health_data")
      channel.setMethodCallHandler(HealthDataPlugin())
    }
  }

  /// Handle calls from the MethodChannel
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "requestAuthorization" -> requestAuthorization(call, result)
      "getDataByStartAndEndDate" -> getDataByStartAndEndDate(call, result)
      "getDataCumulativeByDay" -> getDataCumulativeByDay(call, result)
      "getDataLatestAvailable" -> getDataLatestAvailable(call, result)
      else -> result.notImplemented()
    }
  }


  /// DataTypes to register
  private val fitnessOptions = FitnessOptions.builder()
          .addDataType(getDataType(BODY_FAT_PERCENTAGE), FitnessOptions.ACCESS_READ)
          .addDataType(getDataType(HEIGHT), FitnessOptions.ACCESS_READ)
          .addDataType(getDataType(WEIGHT), FitnessOptions.ACCESS_READ)
          .addDataType(getDataType(STEPS), FitnessOptions.ACCESS_READ)
          .addDataType(getDataType(ACTIVE_ENERGY_BURNED), FitnessOptions.ACCESS_READ)
          .addDataType(getDataType(HEART_RATE), FitnessOptions.ACCESS_READ)
          .addDataType(getDataType(BODY_TEMPERATURE), FitnessOptions.ACCESS_READ)
          .addDataType(getDataType(BLOOD_PRESSURE_SYSTOLIC), FitnessOptions.ACCESS_READ)
          .addDataType(getDataType(BLOOD_OXYGEN), FitnessOptions.ACCESS_READ)
          .addDataType(getDataType(BLOOD_GLUCOSE), FitnessOptions.ACCESS_READ)
          .build()

  override fun success(p0: Any?) {
    handler?.post(
            Runnable { result?.success(p0) })
  }

  override fun notImplemented() {
    handler?.post(
            Runnable { result?.notImplemented() })
  }

  override fun error(
          errorCode: String, errorMessage: String?, errorDetails: Any?) {
    handler?.post(
            Runnable { result?.error(errorCode, errorMessage, errorDetails) })
  }

  private var mResult: Result? = null

  private fun getDataType(type: String): DataType {
    return when (type) {
      BODY_FAT_PERCENTAGE -> DataType.TYPE_BODY_FAT_PERCENTAGE
      HEIGHT -> DataType.TYPE_HEIGHT
      WEIGHT -> DataType.TYPE_WEIGHT
      STEPS -> DataType.TYPE_STEP_COUNT_DELTA
      ACTIVE_ENERGY_BURNED -> DataType.TYPE_CALORIES_EXPENDED
      HEART_RATE -> DataType.TYPE_HEART_RATE_BPM
      BODY_TEMPERATURE -> HealthDataTypes.TYPE_BODY_TEMPERATURE
      BLOOD_PRESSURE_SYSTOLIC -> HealthDataTypes.TYPE_BLOOD_PRESSURE
      BLOOD_PRESSURE_DIASTOLIC -> HealthDataTypes.TYPE_BLOOD_PRESSURE
      BLOOD_OXYGEN -> HealthDataTypes.TYPE_OXYGEN_SATURATION
      BLOOD_GLUCOSE -> HealthDataTypes.TYPE_BLOOD_GLUCOSE
      else -> DataType.TYPE_STEP_COUNT_DELTA
    }
  }

  private fun getDataTypeAggregate(type: String): DataType {
    return when (type) {
      BODY_FAT_PERCENTAGE -> DataType.TYPE_BODY_FAT_PERCENTAGE
      HEIGHT -> DataType.TYPE_HEIGHT
      WEIGHT -> DataType.TYPE_WEIGHT
      STEPS -> DataType.AGGREGATE_STEP_COUNT_DELTA
      ACTIVE_ENERGY_BURNED -> DataType.AGGREGATE_CALORIES_EXPENDED
      HEART_RATE -> DataType.TYPE_HEART_RATE_BPM
      BODY_TEMPERATURE -> HealthDataTypes.TYPE_BODY_TEMPERATURE
      BLOOD_PRESSURE_SYSTOLIC -> HealthDataTypes.TYPE_BLOOD_PRESSURE
      BLOOD_PRESSURE_DIASTOLIC -> HealthDataTypes.TYPE_BLOOD_PRESSURE
      BLOOD_OXYGEN -> HealthDataTypes.TYPE_OXYGEN_SATURATION
      BLOOD_GLUCOSE -> HealthDataTypes.TYPE_BLOOD_GLUCOSE
      else -> DataType.TYPE_STEP_COUNT_DELTA
    }
  }

  private fun getUnit(type: String): Field {
    return when (type) {
      BODY_FAT_PERCENTAGE -> Field.FIELD_PERCENTAGE
      HEIGHT -> Field.FIELD_HEIGHT
      WEIGHT -> Field.FIELD_WEIGHT
      STEPS -> Field.FIELD_STEPS
      ACTIVE_ENERGY_BURNED -> Field.FIELD_CALORIES
      HEART_RATE -> Field.FIELD_BPM
      BODY_TEMPERATURE -> HealthFields.FIELD_BODY_TEMPERATURE
      BLOOD_PRESSURE_SYSTOLIC -> HealthFields.FIELD_BLOOD_PRESSURE_SYSTOLIC
      BLOOD_PRESSURE_DIASTOLIC -> HealthFields.FIELD_BLOOD_PRESSURE_DIASTOLIC
      BLOOD_OXYGEN -> HealthFields.FIELD_OXYGEN_SATURATION
      BLOOD_GLUCOSE -> HealthFields.FIELD_BLOOD_GLUCOSE_LEVEL
      else -> Field.FIELD_PERCENTAGE
    }
  }

  /// Extracts the (numeric) value from a Health Data Point
  private fun getHealthDataValue(dataPoint: DataPoint, unit: Field): Any {
    return try {
      dataPoint.getValue(unit).asFloat()
    } catch (e1: Exception) {
      try {
        dataPoint.getValue(unit).asInt()
      } catch (e2: Exception) {
        try {
          dataPoint.getValue(unit).asString()
        } catch (e3: Exception) {
          Log.e("HEALTH_DATA::ERROR", e3.toString())
        }
      }
    }
  }

  private fun getDataLatestAvailable(call: MethodCall, result: Result) {
    val type = call.argument<String>("dataTypeKey")!!
    val calendar: Calendar = Calendar.getInstance()
    val dataType = getDataType(type)
    val unit = getUnit(type)

    thread {
      val googleSignInAccount = GoogleSignIn.getAccountForExtension(activity!!.applicationContext, fitnessOptions)

      val response = Fitness.getHistoryClient(activity?.applicationContext!!, googleSignInAccount)
              .readData(DataReadRequest.Builder()
                      .read(dataType)
                      .setTimeRange(1, calendar.timeInMillis, TimeUnit.MILLISECONDS)
                      .setLimit(1)
                      .build())

      val dataPoints = Tasks.await<DataReadResponse>(response).getDataSet(dataType)

      val healthData = dataPoints.dataPoints.mapIndexed { _, dataPoint ->
        return@mapIndexed hashMapOf(
                "value" to getHealthDataValue(dataPoint, unit),
                "date_from" to dataPoint.getStartTime(TimeUnit.MILLISECONDS),
                "date_to" to dataPoint.getEndTime(TimeUnit.MILLISECONDS),
                "unit" to unit.toString()
        )

      }
      activity!!.runOnUiThread { result.success(healthData) }
    }
  }

  private fun getDataCumulativeByDay(call: MethodCall, result: Result) {
    val type = call.argument<String>("dataTypeKey")!!
    val startTime = call.argument<Long>("startDate")!!
    val endTime = call.argument<Long>("endDate")!!

    val dataType = getDataType(type)
    val aggregateType = getDataTypeAggregate(type)
    val unit = getUnit(type)

    thread {
      val googleSignInAccount = GoogleSignIn.getAccountForExtension(activity!!.applicationContext, fitnessOptions)

      val response = Fitness.getHistoryClient(activity?.applicationContext!!, googleSignInAccount)
              .readData(DataReadRequest.Builder()
                      .aggregate(dataType, aggregateType)
                      .bucketByTime(1, TimeUnit.DAYS)
                      .setTimeRange(startTime, endTime, TimeUnit.MILLISECONDS)
                      .build())

      val buckets = Tasks.await<DataReadResponse>(response).buckets

      val healthData : MutableList<HashMap<String, Any>> = mutableListOf()

      buckets.forEach {
        it.getDataSet(dataType)?.dataPoints?.mapIndexed { _, dataPoint ->
          healthData.add(hashMapOf(
                  "value" to getHealthDataValue(dataPoint, unit),
                  "date_from" to dataPoint.getStartTime(TimeUnit.MILLISECONDS),
                  "date_to" to dataPoint.getEndTime(TimeUnit.MILLISECONDS),
                  "unit" to unit.toString()
          ))
        }
      }
      activity!!.runOnUiThread { result.success(healthData) }
    }
  }


  private fun getDataByStartAndEndDate(call: MethodCall, result: Result) {
    val type = call.argument<String>("dataTypeKey")!!
    val startTime = call.argument<Long>("startDate")!!
    val endTime = call.argument<Long>("endDate")!!
    val dataType = getDataType(type)
    val unit = getUnit(type)

    thread {
      val googleSignInAccount = GoogleSignIn.getAccountForExtension(activity!!.applicationContext, fitnessOptions)

      val response = Fitness.getHistoryClient(activity?.applicationContext!!, googleSignInAccount)
              .readData(DataReadRequest.Builder()
                      .read(dataType)
                      .setTimeRange(startTime, endTime, TimeUnit.MILLISECONDS)
                      .build())

      val dataPoints = Tasks.await<DataReadResponse>(response).getDataSet(dataType)

      val healthData = dataPoints.dataPoints.mapIndexed { _, dataPoint ->
        return@mapIndexed hashMapOf(
                "value" to getHealthDataValue(dataPoint, unit),
                "date_from" to dataPoint.getStartTime(TimeUnit.MILLISECONDS),
                "date_to" to dataPoint.getEndTime(TimeUnit.MILLISECONDS),
                "unit" to unit.toString()
        )

      }
      activity!!.runOnUiThread { result.success(healthData) }
    }
  }
  
  private fun requestAuthorization(call: MethodCall, result: Result) {
    mResult = result
    if (!GoogleSignIn.hasPermissions(GoogleSignIn.getLastSignedInAccount(activity), fitnessOptions)) {
      activity?.let {
        GoogleSignIn.requestPermissions(
                it,
                GOOGLE_FIT_PERMISSIONS_REQUEST_CODE,
                GoogleSignIn.getLastSignedInAccount(activity),
                fitnessOptions)
      }
    } else {
      mResult?.success(true)
      Log.d("HEALTH_DATA", "Access already granted before!")
    }

  }



  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (resultCode == Activity.RESULT_OK) {
      if (requestCode == GOOGLE_FIT_PERMISSIONS_REQUEST_CODE) {
        Log.d("HEALTH_DATA", "Access Granted!")
        mResult?.success(true)
      } else {
        Log.d("HEALTH_DATA", "Access Denied!")
      }
    }
    return false
  }


}
