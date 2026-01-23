package com.example.untitled

import android.os.BatteryManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.pm.PackageManager
import android.os.Build
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private val BATTERY_CHANNEL = "com.example.battery/info"
    private val BT_CHANNEL = "samples.flutter.dev/bluetooth"
    private val CPU_CHANNEL = "com.example.cpu/info"
    private val STORAGE_CHANNEL = "storage/info"
    private val OS_CHANNEL = "device/os"

    private val REQUEST_BT_PERMISSION = 1

    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private var connectedDevicesList: MutableList<Map<String, String>> = mutableListOf()
    private lateinit var receiver: BroadcastReceiver

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        /* =====================
           バッテリー情報
        ===================== */
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL)
            .setMethodCallHandler { call, result ->
                val batteryManager =
                    getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                when (call.method) {
                    "getChargingSpeed" -> {
                        val currentNow =
                            batteryManager.getIntProperty(
                                BatteryManager.BATTERY_PROPERTY_CURRENT_NOW
                            )
                        result.success(currentNow)
                    }
                    "getBatteryDetails" -> {
                        val intent =
                            registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                        val voltage =
                            intent?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1)
                        val temperature =
                            intent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
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

        /* =====================
           Bluetooth情報
        ===================== */
        if (checkBluetoothPermission()) {
            setupBluetooth()
        } else {
            requestBluetoothPermission()
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BT_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getPairedDevices") {
                    result.success(connectedDevicesList)
                } else {
                    result.notImplemented()
                }
            }

        /* =====================
           CPU周波数情報
        ===================== */
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CPU_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getCpuFrequency" -> result.success(getCpuFrequency())
                    else -> result.notImplemented()
                }
            }

        /* =====================
           ストレージ情報
        ===================== */
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STORAGE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getStorageInfo" -> {
                        try {
                            val stat = StatFs(filesDir.path)
                            val totalBytes =
                                stat.blockSizeLong * stat.blockCountLong
                            val freeBytes =
                                stat.blockSizeLong * stat.availableBlocksLong

                            result.success(
                                mapOf(
                                    "internalTotal" to totalBytes,
                                    "internalFree" to freeBytes
                                )
                            )
                        } catch (e: Exception) {
                            result.error(
                                "STORAGE_ERROR",
                                "ストレージ取得失敗",
                                e.message
                            )
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        /* =====================
           ⭐ OS / 端末情報
        ===================== */
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getOsInfo" -> {
                        val osVersion = Build.VERSION.RELEASE
                        val sdkInt = Build.VERSION.SDK_INT
                        val manufacturer = Build.MANUFACTURER
                        val model = Build.MODEL

                        result.success(
                            "Android $osVersion (SDK $sdkInt)\n$manufacturer $model"
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /* =====================
       CPU補助
    ===================== */
    private fun getCpuFrequency(): String {
        return try {
            val file =
                File("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq")
            if (file.exists()) {
                val freq = file.readText().trim()
                (freq.toInt() / 1000).toString() // kHz → MHz
            } else {
                "ファイルが存在しません"
            }
        } catch (e: Exception) {
            "取得失敗: ${e.message}"
        }
    }

    /* =====================
       Bluetooth補助
    ===================== */
    private fun checkBluetoothPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            checkSelfPermission(android.Manifest.permission.BLUETOOTH_CONNECT) ==
                PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun requestBluetoothPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            requestPermissions(
                arrayOf(android.Manifest.permission.BLUETOOTH_CONNECT),
                REQUEST_BT_PERMISSION
            )
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_BT_PERMISSION) {
            if (grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            ) {
                setupBluetooth()
            }
        }
    }

    private fun setupBluetooth() {
        updateConnectedDevices()

        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val action = intent?.action
                if (action == BluetoothDevice.ACTION_ACL_CONNECTED ||
                    action == BluetoothDevice.ACTION_ACL_DISCONNECTED
                ) {
                    updateConnectedDevices()
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
            addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        }
        registerReceiver(receiver, filter)
    }

    private fun updateConnectedDevices() {
        connectedDevicesList.clear()
        bluetoothAdapter?.bondedDevices?.forEach { device ->
            if (device.bondState == BluetoothDevice.BOND_BONDED && device.isConnected()) {
                connectedDevicesList.add(
                    mapOf(
                        "name" to (device.name ?: "不明なデバイス"),
                        "address" to device.address
                    )
                )
            }
        }
    }

    private fun BluetoothDevice.isConnected(): Boolean {
        return try {
            val method = javaClass.getMethod("isConnected")
            method.invoke(this) as Boolean
        } catch (e: Exception) {
            false
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (::receiver.isInitialized) {
            unregisterReceiver(receiver)
        }
    }
}
