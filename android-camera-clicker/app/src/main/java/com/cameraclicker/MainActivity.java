package com.cameraclicker;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.cameraclicker.service.CameraService;
import com.cameraclicker.service.BluetoothService;
import com.cameraclicker.util.PermissionManager;
import com.cameraclicker.util.ServiceManager;

/**
 * Main activity for Camera Clicker Android app
 * Handles user interface and service management
 * 
 * @author DrKhiLL
 */
public class MainActivity extends AppCompatActivity {
    
    private static final int PERMISSION_REQUEST_CODE = 1001;
    
    private Button startServiceButton;
    private Button stopServiceButton;
    private TextView statusText;
    private TextView connectionText;
    
    private ServiceManager serviceManager;
    private PermissionManager permissionManager;
    
    private boolean isServiceRunning = false;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        initializeViews();
        initializeManagers();
        setupClickListeners();
        checkPermissions();
    }
    
    private void initializeViews() {
        startServiceButton = findViewById(R.id.btn_start_service);
        stopServiceButton = findViewById(R.id.btn_stop_service);
        statusText = findViewById(R.id.tv_status);
        connectionText = findViewById(R.id.tv_connection);
        
        updateUI();
    }
    
    private void initializeManagers() {
        serviceManager = new ServiceManager(this);
        permissionManager = new PermissionManager(this);
    }
    
    private void setupClickListeners() {
        startServiceButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startCameraClicker();
            }
        });
        
        stopServiceButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                stopCameraClicker();
            }
        });
    }
    
    private void checkPermissions() {
        if (!permissionManager.hasAllRequiredPermissions()) {
            permissionManager.requestPermissions(this, PERMISSION_REQUEST_CODE);
        }
    }
    
    private void startCameraClicker() {
        if (!permissionManager.hasAllRequiredPermissions()) {
            Toast.makeText(this, "Please grant all required permissions", Toast.LENGTH_LONG).show();
            checkPermissions();
            return;
        }
        
        try {
            serviceManager.startCameraService();
            serviceManager.startBluetoothService();
            
            isServiceRunning = true;
            updateUI();
            
            Toast.makeText(this, "Camera Clicker started successfully", Toast.LENGTH_SHORT).show();
            
        } catch (Exception e) {
            Toast.makeText(this, "Failed to start Camera Clicker: " + e.getMessage(), Toast.LENGTH_LONG).show();
        }
    }
    
    private void stopCameraClicker() {
        try {
            serviceManager.stopCameraService();
            serviceManager.stopBluetoothService();
            
            isServiceRunning = false;
            updateUI();
            
            Toast.makeText(this, "Camera Clicker stopped", Toast.LENGTH_SHORT).show();
            
        } catch (Exception e) {
            Toast.makeText(this, "Error stopping Camera Clicker: " + e.getMessage(), Toast.LENGTH_LONG).show();
        }
    }
    
    private void updateUI() {
        if (isServiceRunning) {
            statusText.setText("Camera Clicker Active");
            statusText.setTextColor(getResources().getColor(R.color.success_green));
            startServiceButton.setVisibility(View.GONE);
            stopServiceButton.setVisibility(View.VISIBLE);
            connectionText.setText("Ready for Garmin connection");
        } else {
            statusText.setText("Camera Clicker Inactive");
            statusText.setTextColor(getResources().getColor(R.color.secondary_text));
            startServiceButton.setVisibility(View.VISIBLE);
            stopServiceButton.setVisibility(View.GONE);
            connectionText.setText("Service not running");
        }
    }
    
    public void updateConnectionStatus(String status) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                connectionText.setText(status);
            }
        });
    }
    
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        
        if (requestCode == PERMISSION_REQUEST_CODE) {
            boolean allGranted = true;
            for (int result : grantResults) {
                if (result != PackageManager.PERMISSION_GRANTED) {
                    allGranted = false;
                    break;
                }
            }
            
            if (allGranted) {
                Toast.makeText(this, "All permissions granted", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, "Some permissions were denied. App may not work correctly.", Toast.LENGTH_LONG).show();
            }
        }
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        // Check if services are actually running
        isServiceRunning = serviceManager.isCameraServiceRunning() && serviceManager.isBluetoothServiceRunning();
        updateUI();
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Services continue running in background
        // Only stop if user explicitly requested it
    }
}

