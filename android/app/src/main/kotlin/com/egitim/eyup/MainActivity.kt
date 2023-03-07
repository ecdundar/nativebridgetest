package com.egitim.eyup

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.BatteryManager
import android.os.Build
import android.widget.Toast
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val METHODCHANNELNAME = "flutter.burulas/battery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHODCHANNELNAME).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val level = getBatteryLevel()
                if (level >= 0) {
                    result.success(level)
                } else {
                    result.error("EXCEPTION","Pil durumu okunamadı.","Detay bilgiler")
                }
            }
            if (call.method == "showToast") {
                val mesaj : String? = call.argument("Mesaj")
                Toast.makeText(applicationContext,mesaj,Toast.LENGTH_SHORT).show()
                result.success(true)
            }
            if (call.method == "checkBluetooth") {
                result.success(checkBluetooth())
            }
            if (call.method == "getBluetoothIsOpen") {
                result.success(getBluetoothIsOpen())
            }
            if (call.method == "openBluetooth") {
                result.success(openBluetooth())
            }
            if (call.method == "closeBluetooth") {
                result.success(closeBluetooth())
            }
        }
    }

    @SuppressLint("MissingPermission")
    private fun openBluetooth() : Boolean {
        var result = false
        val manager = this.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val mBluetoothAdapter = manager.getAdapter()
        if (mBluetoothAdapter != null) {
            if (!mBluetoothAdapter.isEnabled) {
                if (ActivityCompat.checkSelfPermission(
                        this,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    Toast.makeText(this,"Bluetooth açma-kapatma yetkisi bulunmuyor.",Toast.LENGTH_SHORT).show();
                    return false
                }
                manager.adapter.enable();
                result = true
            } else {
                result = true
            }
        }
        return result
    }
    @SuppressLint("MissingPermission")
    private fun closeBluetooth() : Boolean {
        var result = false
        val manager = this.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val mBluetoothAdapter = manager.getAdapter()
        if (mBluetoothAdapter != null) {
            if (mBluetoothAdapter.isEnabled) {
                if (ActivityCompat.checkSelfPermission(
                        this,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    Toast.makeText(this,"Bluetooth açma-kapatma yetkisi bulunmuyor.",Toast.LENGTH_SHORT).show();
                    return false
                }
                manager.adapter.disable();
                result = true
            } else {
                result = true
            }
        }
        return result
    }
    private fun getBluetoothIsOpen() : Boolean {
        var result = false
        val manager = this.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        if (manager.adapter != null) {
            result = manager.adapter.isEnabled
        }
        return result
    }

    private fun checkBluetooth() : Boolean {
        var result = false
        val manager = this.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        if (manager.adapter != null) {
            result = true
        }
        return result
    }

    private fun getBatteryLevel() : Int {
        var level : Int = 0
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val manager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            level = manager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(
                Intent.ACTION_BATTERY_CHANGED))
            level = (intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL,-1) * 100) / intent!!.getIntExtra(BatteryManager.EXTRA_SCALE,-1)
        }
        return level
    }

}
