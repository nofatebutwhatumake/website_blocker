package com.example.website_blocker

import android.content.Intent
import android.net.VpnService
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.website_blocker/vpn"
    private val TAG = "MainActivity"
    private val VPN_REQUEST_CODE = 0x0F

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "startVpn" -> {
                        val domains = call.argument<List<String>>("blockedDomains")
                        startVpnService(domains)
                        result.success(true)
                    }
                    "stopVpn" -> {
                        stopVpnService()
                        result.success(true)
                    }
                    "updateBlockedDomains" -> {
                        val domains = call.argument<List<String>>("blockedDomains")
                        updateVpnService(domains)
                        result.success(true)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error handling method call: ${call.method}", e)
                result.error("ERROR", e.message, null)
            }
        }
    }

    private fun startVpnService(domains: List<String>?) {
        try {
            val intent = VpnService.prepare(this)
            if (intent != null) {
                startActivityForResult(intent, VPN_REQUEST_CODE)
            } else {
                val serviceIntent = Intent(this, WebsiteBlockerVpnService::class.java)
                serviceIntent.action = "start"
                serviceIntent.putStringArrayListExtra("blockedDomains", ArrayList(domains))
                startService(serviceIntent)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error starting VPN service", e)
        }
    }

    private fun stopVpnService() {
        try {
            val serviceIntent = Intent(this, WebsiteBlockerVpnService::class.java)
            serviceIntent.action = "stop"
            startService(serviceIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping VPN service", e)
        }
    }

    private fun updateVpnService(domains: List<String>?) {
        try {
            val serviceIntent = Intent(this, WebsiteBlockerVpnService::class.java)
            serviceIntent.action = "update"
            serviceIntent.putStringArrayListExtra("blockedDomains", ArrayList(domains))
            startService(serviceIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Error updating VPN service", e)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == VPN_REQUEST_CODE && resultCode == RESULT_OK) {
            try {
                val serviceIntent = Intent(this, WebsiteBlockerVpnService::class.java)
                serviceIntent.action = "start"
                startService(serviceIntent)
            } catch (e: Exception) {
                Log.e(TAG, "Error starting VPN service after permission granted", e)
            }
        }
    }
} 