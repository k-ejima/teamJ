package com.example.untitled // AndroidManifest.xml の package と一致

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val BATTERY_CHANNEL = "com.example.battery/info"
    private val BT_CHANNEL = "samples.flutter.dev/bluetooth"
    private val REQUEST_BT_PERMISSION = 1

    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private var connectedDevicesList: MutableList<Map<String, String>> = mutableListOf()
    private lateinit var receiver: BroadcastReceiver

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // --- バッテリー情報 ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL)
            .setMethodCallHandler { call, result ->
                val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                when (call.method) {
                    "getChargingSpeed" -> {
                        val currentNow = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
                        result.success(currentNow)
                    }
                    "getBatteryDetails" -> {
                        val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                        val voltage = intent?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1)
                        val temperature = intent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
                        result.success(mapOf("voltage" to voltage, "temperature" to temperature))
                    }
                    else -> result.notImplemented()
                }
            }

        // --- Bluetooth権限確認 & 初期セットアップ ---
        if (checkBluetoothPermission()) {
            setupBluetooth()
        } else {
            requestBluetoothPermission()
        }

        // Flutterから接続中デバイスを取得
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BT_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getPairedDevices") {
                    // 最新の接続デバイスリストを返す
                    result.success(connectedDevicesList)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun checkBluetoothPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            checkSelfPermission(android.Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
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

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_BT_PERMISSION) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                setupBluetooth()
            }
        }
    }

    private fun setupBluetooth() {
        updateConnectedDevices()

        // 接続/切断イベントを監視
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

    // BluetoothDevice.isConnected() を拡張関数で作成
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
