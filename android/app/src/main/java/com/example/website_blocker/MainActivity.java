// android/app/src/main/java/com/example/website_blocker/MainActivity.java
package com.example.website_blocker;

import androidx.annotation.NonNull;
import android.content.Intent;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.website_blocker/vpn";
    private Set<String> blockedDomains = new HashSet<>();

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "startVpn":
                            List<String> domains = call.argument("blockedDomains");
                            if (domains != null) {
                                blockedDomains.clear();
                                blockedDomains.addAll(domains);
                            }
                            boolean startSuccess = startVpnService();
                            result.success(startSuccess);
                            break;
                        case "stopVpn":
                            boolean stopSuccess = stopVpnService();
                            result.success(stopSuccess);
                            break;
                        case "updateBlockedDomains":
                            List<String> newDomains = call.argument("blockedDomains");
                            boolean updateSuccess = updateBlockedDomains(newDomains);
                            result.success(updateSuccess);
                            break;
                        default:
                            result.notImplemented();
                            break;
                    }
                }
            );
    }

    private boolean startVpnService() {
        try {
            Intent vpnIntent = android.net.VpnService.prepare(this);
            
            if (vpnIntent != null) {
                startActivityForResult(vpnIntent, 0);
                return false; // Not immediately successful, awaiting user confirmation
            } else {
                // Already has permission, start the service
                Intent intent = new Intent(this, VpnService.class);
                intent.putExtra("blockedDomains", blockedDomains.toArray(new String[0]));
                startService(intent);
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    private boolean stopVpnService() {
        try {
            stopService(new Intent(this, VpnService.class));
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    private boolean updateBlockedDomains(List<String> domains) {
        try {
            if (domains != null) {
                blockedDomains.clear();
                blockedDomains.addAll(domains);
                
                // If the VPN service is running, update its domains
                Intent intent = new Intent(this, VpnService.class);
                intent.setAction("UPDATE_DOMAINS");
                intent.putExtra("blockedDomains", blockedDomains.toArray(new String[0]));
                startService(intent);
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        
        if (requestCode == 0 && resultCode == RESULT_OK) {
            // VPN permission was granted, start the service
            Intent intent = new Intent(this, VpnService.class);
            intent.putExtra("blockedDomains", blockedDomains.toArray(new String[0]));
            startService(intent);
        }
    }
}