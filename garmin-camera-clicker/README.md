# Garmin Camera Clicker - Connect IQ App

A Connect IQ application that turns your Garmin watch into a remote camera clicker for Android phones.

## Features

- **Remote Photo Capture**: Trigger photo capture on your Android phone from your Garmin watch
- **Camera Switching**: Switch between front and rear cameras
- **Flash Control**: Toggle flash modes (Auto/On/Off)
- **Touch & Button Controls**: Multiple input methods for easy operation
- **Real-time Status**: Visual feedback for connection and camera status

## Compatible Devices

This app is compatible with a wide range of Garmin watches including:

- **Epix Series**: Epix Pro (47mm/51mm), Epix Gen 2
- **Fenix Series**: Fenix 7/7S/7X, Fenix 7 Pro series, Fenix 8 series
- **Venu Series**: Venu 2/2S, Venu 3/3S
- **Vivoactive Series**: Vivoactive 4/4S, Vivoactive 5
- **Forerunner Series**: FR255, FR265, FR955, FR965
- **Approach Series**: Approach S62, S70
- **MARQ Series**: All MARQ models

## Requirements

- Garmin watch with Connect IQ support (API Level 1.4.0+)
- Android phone with companion app installed
- Bluetooth connection between devices

## Installation

1. Install from the Connect IQ Store on your Garmin watch
2. Install the companion Android app on your phone
3. Pair the devices via Bluetooth
4. Launch the Camera Clicker app on your watch

## Usage

### Main Controls
- **Center Button/Tap**: Capture photo
- **Left Side Tap/Swipe**: Switch camera (front/rear)
- **Right Side Tap/Swipe Up**: Toggle flash mode
- **Swipe Down**: Alternative capture trigger

### Status Indicators
- **Green**: Connected and ready
- **Yellow**: Capturing photo
- **Red**: Disconnected or error
- **Connection Status**: Displayed at bottom of screen

## Development

### Building the App

1. Install Connect IQ SDK
2. Open project in Visual Studio Code with Connect IQ extension
3. Build for target device
4. Deploy to watch or simulator

### Project Structure
```
garmin-camera-clicker/
├── manifest.xml              # App configuration
├── resources/
│   ├── strings/strings.xml   # Text resources
│   ├── drawables/            # Icons and images
│   └── resources.xml         # Resource definitions
└── source/
    ├── CameraClickerApp.mc   # Main application class
    ├── CameraClickerView.mc  # User interface
    ├── CameraClickerDelegate.mc # Input handling
    └── CommunicationManager.mc  # Bluetooth communication
```

## Communication Protocol

The app uses Garmin's PhoneAppMessage framework to communicate with the Android companion app via Bluetooth Low Energy (BLE). Messages are formatted as JSON with the following structure:

```json
{
  "messageType": "CAMERA_COMMAND",
  "timestamp": 1721203200000,
  "sequenceNumber": 12345,
  "payload": {
    "command": "CAPTURE_PHOTO",
    "parameters": {
      "camera": "rear",
      "flash": "auto",
      "quality": "high"
    }
  }
}
```

## License

This project is open source and available under the MIT License.

## Support

For issues and feature requests, please contact the developer or submit an issue on the project repository.

