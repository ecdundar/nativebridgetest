package com.egitim.eyup

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.widget.Toast
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
                Toast.makeText(applicationContext,"Native Toast Example",Toast.LENGTH_SHORT).show()
                result.success(true)
            }
        }
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
