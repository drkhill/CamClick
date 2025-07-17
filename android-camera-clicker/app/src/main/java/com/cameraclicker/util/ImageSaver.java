package com.cameraclicker.util;

import android.content.Context;
import android.media.Image;
import android.os.Environment;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * Utility class for saving captured images to storage
 * 
 * @author DrKhiLL
 */
public class ImageSaver {
    
    private static final String TAG = "ImageSaver";
    private Context context;
    
    public ImageSaver(Context context) {
        this.context = context;
    }
    
    public void saveImage(Image image) {
        ByteBuffer buffer = image.getPlanes()[0].getBuffer();
        byte[] bytes = new byte[buffer.remaining()];
        buffer.get(bytes);
        
        String fileName = generateFileName();
        File file = new File(getOutputDirectory(), fileName);
        
        try (FileOutputStream output = new FileOutputStream(file)) {
            output.write(bytes);
            Log.d(TAG, "Image saved: " + file.getAbsolutePath());
        } catch (IOException e) {
            Log.e(TAG, "Failed to save image", e);
        } finally {
            image.close();
        }
    }
    
    private String generateFileName() {
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US);
        return "CameraClicker_" + formatter.format(new Date()) + ".jpg";
    }
    
    private File getOutputDirectory() {
        File picturesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES);
        File cameraClickerDir = new File(picturesDir, "CameraClicker");
        
        if (!cameraClickerDir.exists()) {
            cameraClickerDir.mkdirs();
        }
        
        return cameraClickerDir;
    }
}

