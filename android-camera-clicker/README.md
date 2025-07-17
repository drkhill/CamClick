# Camera Clicker - Android Companion App

**Developer:** DrKhiLL  
**Version:** 1.0

## Overview
Android companion app for the Garmin Camera Clicker system. Receives commands from Garmin watches and controls the phone's camera remotely.

## Features
- Remote photo capture via Garmin watch
- Camera switching (front/rear)
- Flash control (auto/on/off)
- Background service operation
- Professional Camera2 API integration

## Build Instructions
1. Open project in Android Studio
2. Sync Gradle files
3. Build APK: Build → Build Bundle(s)/APK(s) → Build APK(s)
4. Find APK in `app/build/outputs/apk/`

## Requirements
- Android 7.0+ (API 24)
- Camera permission
- Bluetooth permission
- Storage permission

## File Structure
```
app/
├── src/main/
│   ├── java/com/cameraclicker/
│   │   ├── MainActivity.java
│   │   ├── service/
│   │   │   ├── CameraService.java
│   │   │   └── BluetoothService.java
│   │   └── util/
│   │       ├── ImageSaver.java
│   │       ├── PermissionManager.java
│   │       └── ServiceManager.java
│   ├── res/
│   │   ├── layout/activity_main.xml
│   │   └── values/
│   └── AndroidManifest.xml
└── build.gradle
```

## Developer
Created by DrKhiLL for publication on Google Play Store.

