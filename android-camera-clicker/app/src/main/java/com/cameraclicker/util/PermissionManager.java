package com.cameraclicker.util;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

/**
 * Utility class for managing app permissions
 * 
 * @author DrKhiLL
 */
public class PermissionManager {
    
    private Context context;
    
    private static final String[] REQUIRED_PERMISSIONS = {
        Manifest.permission.CAMERA,
        Manifest.permission.WRITE_EXTERNAL_STORAGE,
        Manifest.permission.BLUETOOTH,
        Manifest.permission.BLUETOOTH_ADMIN,
        Manifest.permission.ACCESS_FINE_LOCATION
    };
    
    private static final String[] ANDROID_12_PERMISSIONS = {
        "android.permission.BLUETOOTH_CONNECT",
        "android.permission.BLUETOOTH_SCAN"
    };
    
    public PermissionManager(Context context) {
        this.context = context;
    }
    
    public boolean hasAllRequiredPermissions() {
        for (String permission : REQUIRED_PERMISSIONS) {
            if (ContextCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }
        
        // Check Android 12+ permissions
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            for (String permission : ANDROID_12_PERMISSIONS) {
                if (ContextCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                    return false;
                }
            }
        }
        
        return true;
    }
    
    public void requestPermissions(Activity activity, int requestCode) {
        String[] allPermissions = REQUIRED_PERMISSIONS;
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            String[] combined = new String[REQUIRED_PERMISSIONS.length + ANDROID_12_PERMISSIONS.length];
            System.arraycopy(REQUIRED_PERMISSIONS, 0, combined, 0, REQUIRED_PERMISSIONS.length);
            System.arraycopy(ANDROID_12_PERMISSIONS, 0, combined, REQUIRED_PERMISSIONS.length, ANDROID_12_PERMISSIONS.length);
            allPermissions = combined;
        }
        
        ActivityCompat.requestPermissions(activity, allPermissions, requestCode);
    }
}

