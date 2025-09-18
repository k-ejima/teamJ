package com.example.untitled // ← AndroidManifest.xml の package と一致させてください

import android.content.Context

import android.content.ContextWrapper

import android.content.Intent

import android.content.IntentFilter

import android.os.BatteryManager

import io.flutter.embedding.android.FlutterActivity

import io.flutter.embedding.engine.FlutterEngine

import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.battery/info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager

            when (call.method) {

                "getChargingSpeed" -> {

                    val currentNow = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)

                    result.success(currentNow)

                }

                "getBatteryDetails" -> {

                    val intent = ContextWrapper(applicationContext)

                        .registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))

                    val voltage = intent?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1) // mV

                    val temperature = intent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1) // 0.1℃

                    result.success(

                        mapOf(

                            "voltage" to voltage,

                            "temperature" to temperature

                        )

                    )

                }

                else -> result.notImplemented()

            }

        }

    }

}
 