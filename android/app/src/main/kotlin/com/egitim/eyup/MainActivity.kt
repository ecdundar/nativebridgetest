package com.egitim.eyup

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.*
import android.content.pm.PackageManager
import android.os.BatteryManager
import android.os.Build
import android.os.Handler
import android.util.Log
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.*

class MainActivity: FlutterActivity() {

    private val METHODCHANNELNAME = "flutter.burulas/battery"
    private val EVENTCHANNELNAME = "flutter.burulas/eventChannel"
    private val EVENTCHANNELNAME2 = "flutter.burulas/eventChannel2"

    private var attachEvent: EventChannel.EventSink? = null
    private var count = 1
    private var handler: Handler? = null
    private val numberTask100: Runnable = object : Runnable {
        override fun run() {
            val TOTAL_COUNT = 100
            if (count > TOTAL_COUNT) {
                attachEvent!!.endOfStream()
            } else {
                val percentage = count.toDouble() / TOTAL_COUNT
                attachEvent!!.success(percentage)
            }
            count++
            handler!!.postDelayed(this, 200)
            deneme()
        }
        private fun deneme() {

        }
    }



    private var attachEvent1000: EventChannel.EventSink? = null
    private var count1000 = 1
    private var handler1000: Handler? = null
    private val numberTask1000: Runnable = object : Runnable {
        override fun run() {
            val TOTAL_COUNT = 1000
            if (count1000 > TOTAL_COUNT) {
                attachEvent1000!!.endOfStream()
            } else {
                val percentage = count1000.toDouble() / TOTAL_COUNT
                attachEvent1000!!.success(percentage)
            }
            count1000++
            handler1000!!.postDelayed(this, 10)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
         //EventChanneld i register ediyoruz,
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENTCHANNELNAME2).setStreamHandler(
            object: EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    attachEvent1000 = events
                    count1000 = 1
                    handler1000 = Handler()
                    numberTask1000.run()
                }

                override fun onCancel(arguments: Any?) {
                    handler1000!!.removeCallbacks(numberTask100)
                    handler1000 = null
                    count1000 = 1
                    attachEvent1000 = null
                }
            }
        )

        //EventChanneld i register ediyoruz,
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENTCHANNELNAME).setStreamHandler(
            object: EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    attachEvent = events
                    count = 1
                    handler = Handler()
                    numberTask100.run()
                }

                override fun onCancel(arguments: Any?) {
                    handler!!.removeCallbacks(numberTask100)
                    handler = null
                    count = 1
                    attachEvent = null
                }
            }
        )

        //MethodChannel i register ediyoruz
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
            if (call.method == "printLabel") {
                result.success(printLabel())
            }
        }
    }

    private fun isPermissionsGranted(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED &&
                    ContextCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED &&
                    ContextCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED
        } else {
            ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED &&
                    ContextCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH) == PackageManager.PERMISSION_GRANTED &&
                    ContextCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_ADMIN) == PackageManager.PERMISSION_GRANTED
        }
    }

    var mBluetoothAdapter : BluetoothAdapter? = null
    @SuppressLint("MissingPermission")
    private fun printLabel() : Boolean {
        var result = false

        if (!isPermissionsGranted(this)) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val permissions = mutableSetOf(
                    Manifest.permission.BLUETOOTH,
                    Manifest.permission.BLUETOOTH_ADMIN,
                    Manifest.permission.ACCESS_COARSE_LOCATION,
                    Manifest.permission.ACCESS_FINE_LOCATION
                )
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    permissions.add(Manifest.permission.BLUETOOTH_CONNECT)
                    permissions.add(Manifest.permission.BLUETOOTH_SCAN)
                }
                ActivityCompat.requestPermissions(
                    this, permissions.toTypedArray(), 600
                )
                return result
            }
        }

        val bluetoothManager = this.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        mBluetoothAdapter = bluetoothManager.getAdapter()

        val filter = IntentFilter(BluetoothDevice.ACTION_FOUND)
        registerReceiver(receiver, filter)

        if (mBluetoothAdapter!!.isDiscovering()) {
            mBluetoothAdapter!!.cancelDiscovery();
        }

        mBluetoothAdapter!!.startDiscovery()
        result = true
        return result
    }

    private val receiver = object : BroadcastReceiver() {
        @SuppressLint("MissingPermission")
        override fun onReceive(context: Context, intent: Intent) {
            val action: String? = intent.action
            when(action) {
                BluetoothDevice.ACTION_FOUND -> {
                    val device: BluetoothDevice =
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)!!

                    val deviceName = device.name ?: "NULL"
                    val deviceHardwareAddress = device.address ?: "NULL" // MAC address



                    Log.e("ECD-DEVICENAME",deviceName + " - " + deviceHardwareAddress)
                    if (deviceName.equals("FLUTTERYAZICI")) {

                        Log.e("ECD",device.uuids.get(0).toString())
                        if (mBluetoothAdapter!!.isDiscovering()) {
                            mBluetoothAdapter!!.cancelDiscovery();
                        }
                        connect(device)
                    }
                }
            }
        }
    }

    var mmSocket: BluetoothSocket? = null
    var mmDevice: BluetoothDevice? = null

    var mmOutputStream: OutputStream? = null
    var mmInputStream: InputStream? = null
    var workerThread: Thread? = null

    @SuppressLint("MissingPermission")
    @Throws(IOException::class)
    fun connect(btDevice: BluetoothDevice){
        try {

            // Standard SerialPortService ID
            val uuid = UUID.fromString("00001101-0000-1000-8000-00805f9b34fb")
            mmSocket = btDevice!!.createRfcommSocketToServiceRecord(uuid)
            mmSocket!!.connect()
            mmOutputStream = mmSocket!!.getOutputStream()
            mmInputStream = mmSocket!!.getInputStream()
            //beginListenForData()
            Toast.makeText(this,"Bluetooth Opened",Toast.LENGTH_SHORT).show();
            sendData()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    @Throws(IOException::class)
    fun sendData() {
        try {

            // the text typed by the user
            var msg: String = "! 0 200 200 321 1\r\n" +
                    "PW 384\r\n" +
                    "TONE 0\r\n" +
                    "SPEED 3\r\n" +
                    "ON-FEED IGNORE\r\n" +
                    "NO-PACE\r\n" +
                    "BAR-SENSE\r\n" +
                    "BT 0 0 3\r\n" +
                    "B EAN13 0 20 50 149 42 1234567890128\r\n" +
                    "T 4 0 84 138 BURULAS\r\n" +
                    "T 4 0 110 206 EGITIM\r\n" +
                    "PRINT\r\n"
            mmOutputStream!!.write(msg.toByteArray())

            // tell the user data were sent
            Toast.makeText(this,"Data Sent",Toast.LENGTH_SHORT).show();

            Handler().postDelayed({
                mmSocket!!.close()
            }, 5000)
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
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
