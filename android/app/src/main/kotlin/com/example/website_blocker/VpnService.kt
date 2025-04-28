package com.example.website_blocker

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.system.OsConstants
import androidx.core.app.NotificationCompat
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.InetAddress
import java.util.concurrent.atomic.AtomicBoolean

class WebsiteBlockerVpnService : VpnService() {
    private var vpnInterface: ParcelFileDescriptor? = null
    private val isRunning = AtomicBoolean(false)
    private var blockedDomains: Set<String> = emptySet()

    companion object {
        private const val NOTIFICATION_ID = 1
        private const val CHANNEL_ID = "vpn_service_channel"
        private const val CHANNEL_NAME = "VPN Service"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Website Blocker VPN")
            .setContentText("VPN is active")
            .setSmallIcon(R.drawable.ic_launcher)
            .setContentIntent(pendingIntent)
            .build()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        try {
            when (intent?.action) {
                "start" -> {
                    val domains = intent.getStringArrayListExtra("blockedDomains")?.toSet() ?: emptySet()
                    startVpn(domains)
                }
                "stop" -> stopVpn()
                "update" -> {
                    val domains = intent.getStringArrayListExtra("blockedDomains")?.toSet() ?: emptySet()
                    updateBlockedDomains(domains)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            stopSelf()
        }
        return START_STICKY
    }

    private fun startVpn(domains: Set<String>) {
        if (isRunning.get()) return

        try {
            val builder = VpnService.Builder()
                .setSession("Website Blocker VPN")
                .addAddress("10.0.0.2", 32)
                .addDnsServer("8.8.8.8")
                .addDnsServer("8.8.4.4")
                .addRoute("0.0.0.0", 0)

            vpnInterface = builder.establish()
            blockedDomains = domains
            isRunning.set(true)

            startForeground(NOTIFICATION_ID, createNotification())
            Thread { runVpn() }.start()
        } catch (e: Exception) {
            e.printStackTrace()
            stopSelf()
        }
    }

    private fun stopVpn() {
        try {
            isRunning.set(false)
            vpnInterface?.close()
            vpnInterface = null
            stopForeground(true)
            stopSelf()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun updateBlockedDomains(domains: Set<String>) {
        blockedDomains = domains
    }

    private fun runVpn() {
        try {
            val input = FileInputStream(vpnInterface?.fileDescriptor)
            val output = FileOutputStream(vpnInterface?.fileDescriptor)
            val buffer = ByteArray(32767)

            while (isRunning.get()) {
                val length = input.read(buffer)
                if (length > 0) {
                    if (!shouldBlockPacket(buffer, length)) {
                        output.write(buffer, 0, length)
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            stopSelf()
        }
    }

    private fun shouldBlockPacket(packet: ByteArray, length: Int): Boolean {
        if (length < 12) return false

        try {
            // Check if it's a DNS query
            if (packet[2] and 0x80.toByte() == 0.toByte()) {
                val domain = extractDomain(packet, length)
                return blockedDomains.any { domain.contains(it) }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return false
    }

    private fun extractDomain(packet: ByteArray, length: Int): String {
        var domain = ""
        var offset = 12 // Skip DNS header

        try {
            while (offset < length && packet[offset] != 0.toByte()) {
                val labelLength = packet[offset].toInt() and 0xFF
                offset++

                if (offset + labelLength > length) break

                val label = String(packet, offset, labelLength)
                domain += label + "."
                offset += labelLength
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return domain
    }

    override fun onDestroy() {
        super.onDestroy()
        stopVpn()
    }
} 