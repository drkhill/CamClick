package com.cameraclicker.util;

import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;

import com.cameraclicker.service.BluetoothService;
import com.cameraclicker.service.CameraService;

/**
 * Utility class for managing app services
 * 
 * @author DrKhiLL
 */
public class ServiceManager {
    
    private Context context;
    
    public ServiceManager(Context context) {
        this.context = context;
    }
    
    public void startCameraService() {
        Intent intent = new Intent(context, CameraService.class);
        context.startForegroundService(intent);
    }
    
    public void stopCameraService() {
        Intent intent = new Intent(context, CameraService.class);
        context.stopService(intent);
    }
    
    public void startBluetoothService() {
        Intent intent = new Intent(context, BluetoothService.class);
        context.startService(intent);
    }
    
    public void stopBluetoothService() {
        Intent intent = new Intent(context, BluetoothService.class);
        context.stopService(intent);
    }
    
    public boolean isCameraServiceRunning() {
        return isServiceRunning(CameraService.class);
    }
    
    public boolean isBluetoothServiceRunning() {
        return isServiceRunning(BluetoothService.class);
    }
    
    private boolean isServiceRunning(Class<?> serviceClass) {
        ActivityManager manager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (serviceClass.getName().equals(service.service.getClassName())) {
                return true;
            }
        }
        return false;
    }
}

