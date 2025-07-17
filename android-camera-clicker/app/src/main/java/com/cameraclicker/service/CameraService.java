package com.cameraclicker.service;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.ImageFormat;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.TotalCaptureResult;
import android.media.Image;
import android.media.ImageReader;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.util.Log;
import android.util.Size;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;

import com.cameraclicker.R;
import com.cameraclicker.util.ImageSaver;

import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;

/**
 * Background service for handling camera operations
 * Uses Camera2 API for professional-quality photo capture
 * 
 * @author DrKhiLL
 */
public class CameraService extends Service {
    
    private static final String TAG = "CameraService";
    private static final String CHANNEL_ID = "CameraClickerChannel";
    private static final int NOTIFICATION_ID = 1001;
    
    private CameraManager cameraManager;
    private CameraDevice cameraDevice;
    private CameraCaptureSession captureSession;
    private ImageReader imageReader;
    private Handler backgroundHandler;
    private HandlerThread backgroundThread;
    
    private String currentCameraId = "0"; // Default to rear camera
    private boolean flashEnabled = false;
    private String flashMode = "auto"; // auto, on, off
    
    private ImageSaver imageSaver;
    
    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "CameraService created");
        
        cameraManager = (CameraManager) getSystemService(Context.CAMERA_SERVICE);
        imageSaver = new ImageSaver(this);
        
        createNotificationChannel();
        startForeground(NOTIFICATION_ID, createNotification());
        
        startBackgroundThread();
        initializeCamera();
    }
    
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "CameraService started");
        
        if (intent != null) {
            String action = intent.getStringExtra("action");
            if (action != null) {
                handleCameraCommand(action, intent);
            }
        }
        
        return START_STICKY; // Restart if killed
    }
    
    @Override
    public IBinder onBind(Intent intent) {
        return null; // Not a bound service
    }
    
    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "CameraService destroyed");
        
        closeCamera();
        stopBackgroundThread();
    }
    
    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                CHANNEL_ID,
                "Camera Clicker Service",
                NotificationManager.IMPORTANCE_LOW
            );
            channel.setDescription("Background service for camera remote control");
            
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(channel);
        }
    }
    
    private Notification createNotification() {
        return new NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Camera Clicker Active")
            .setContentText("Ready to receive commands from Garmin watch")
            .setSmallIcon(R.drawable.ic_camera)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build();
    }
    
    private void startBackgroundThread() {
        backgroundThread = new HandlerThread("CameraBackground");
        backgroundThread.start();
        backgroundHandler = new Handler(backgroundThread.getLooper());
    }
    
    private void stopBackgroundThread() {
        if (backgroundThread != null) {
            backgroundThread.quitSafely();
            try {
                backgroundThread.join();
                backgroundThread = null;
                backgroundHandler = null;
            } catch (InterruptedException e) {
                Log.e(TAG, "Error stopping background thread", e);
            }
        }
    }
    
    private void initializeCamera() {
        try {
            setupImageReader();
            openCamera();
        } catch (Exception e) {
            Log.e(TAG, "Failed to initialize camera", e);
        }
    }
    
    private void setupImageReader() {
        try {
            CameraCharacteristics characteristics = cameraManager.getCameraCharacteristics(currentCameraId);
            Size[] jpegSizes = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)
                .getOutputSizes(ImageFormat.JPEG);
            
            // Use the largest available size
            Size largestSize = Collections.max(Arrays.asList(jpegSizes), new CompareSizesByArea());
            
            imageReader = ImageReader.newInstance(largestSize.getWidth(), largestSize.getHeight(),
                ImageFormat.JPEG, 1);
            
            imageReader.setOnImageAvailableListener(new ImageReader.OnImageAvailableListener() {
                @Override
                public void onImageAvailable(ImageReader reader) {
                    Image image = reader.acquireLatestImage();
                    if (image != null) {
                        imageSaver.saveImage(image);
                    }
                }
            }, backgroundHandler);
            
        } catch (CameraAccessException e) {
            Log.e(TAG, "Failed to setup image reader", e);
        }
    }
    
    private void openCamera() {
        try {
            cameraManager.openCamera(currentCameraId, new CameraDevice.StateCallback() {
                @Override
                public void onOpened(@NonNull CameraDevice camera) {
                    Log.d(TAG, "Camera opened successfully");
                    cameraDevice = camera;
                    createCaptureSession();
                }
                
                @Override
                public void onDisconnected(@NonNull CameraDevice camera) {
                    Log.w(TAG, "Camera disconnected");
                    camera.close();
                    cameraDevice = null;
                }
                
                @Override
                public void onError(@NonNull CameraDevice camera, int error) {
                    Log.e(TAG, "Camera error: " + error);
                    camera.close();
                    cameraDevice = null;
                }
            }, backgroundHandler);
            
        } catch (CameraAccessException | SecurityException e) {
            Log.e(TAG, "Failed to open camera", e);
        }
    }
    
    private void createCaptureSession() {
        try {
            if (cameraDevice == null || imageReader == null) {
                Log.e(TAG, "Camera device or image reader is null");
                return;
            }
            
            cameraDevice.createCaptureSession(
                Arrays.asList(imageReader.getSurface()),
                new CameraCaptureSession.StateCallback() {
                    @Override
                    public void onConfigured(@NonNull CameraCaptureSession session) {
                        Log.d(TAG, "Capture session configured");
                        captureSession = session;
                    }
                    
                    @Override
                    public void onConfigureFailed(@NonNull CameraCaptureSession session) {
                        Log.e(TAG, "Failed to configure capture session");
                    }
                },
                backgroundHandler
            );
            
        } catch (CameraAccessException e) {
            Log.e(TAG, "Failed to create capture session", e);
        }
    }
    
    private void handleCameraCommand(String action, Intent intent) {
        switch (action) {
            case "CAPTURE_PHOTO":
                capturePhoto();
                break;
            case "SWITCH_CAMERA":
                String camera = intent.getStringExtra("camera");
                switchCamera(camera);
                break;
            case "SET_FLASH":
                String flash = intent.getStringExtra("flash");
                setFlashMode(flash);
                break;
            default:
                Log.w(TAG, "Unknown camera command: " + action);
        }
    }
    
    public void capturePhoto() {
        if (captureSession == null || cameraDevice == null) {
            Log.e(TAG, "Camera not ready for capture");
            return;
        }
        
        try {
            CaptureRequest.Builder captureBuilder = cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);
            captureBuilder.addTarget(imageReader.getSurface());
            
            // Set flash mode
            setFlashForCapture(captureBuilder);
            
            // Set auto-focus and auto-exposure
            captureBuilder.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);
            captureBuilder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
            
            CaptureRequest captureRequest = captureBuilder.build();
            
            captureSession.capture(captureRequest, new CameraCaptureSession.CaptureCallback() {
                @Override
                public void onCaptureCompleted(@NonNull CameraCaptureSession session,
                                             @NonNull CaptureRequest request,
                                             @NonNull TotalCaptureResult result) {
                    Log.d(TAG, "Photo captured successfully");
                }
            }, backgroundHandler);
            
        } catch (CameraAccessException e) {
            Log.e(TAG, "Failed to capture photo", e);
        }
    }
    
    private void setFlashForCapture(CaptureRequest.Builder captureBuilder) {
        switch (flashMode) {
            case "on":
                captureBuilder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_ALWAYS_FLASH);
                break;
            case "off":
                captureBuilder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
                captureBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
                break;
            case "auto":
            default:
                captureBuilder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH);
                break;
        }
    }
    
    public void switchCamera(String camera) {
        String newCameraId = "front".equals(camera) ? "1" : "0";
        
        if (!newCameraId.equals(currentCameraId)) {
            currentCameraId = newCameraId;
            closeCamera();
            initializeCamera();
            Log.d(TAG, "Switched to " + camera + " camera");
        }
    }
    
    public void setFlashMode(String mode) {
        flashMode = mode;
        Log.d(TAG, "Flash mode set to: " + mode);
    }
    
    private void closeCamera() {
        if (captureSession != null) {
            captureSession.close();
            captureSession = null;
        }
        
        if (cameraDevice != null) {
            cameraDevice.close();
            cameraDevice = null;
        }
        
        if (imageReader != null) {
            imageReader.close();
            imageReader = null;
        }
    }
    
    // Helper class for comparing sizes
    private static class CompareSizesByArea implements Comparator<Size> {
        @Override
        public int compare(Size lhs, Size rhs) {
            return Long.signum((long) lhs.getWidth() * lhs.getHeight() -
                             (long) rhs.getWidth() * rhs.getHeight());
        }
    }
}

