import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

/**
 * Camera Clicker Input Delegate
 * Handles user input events including button presses and touch interactions
 */
class CameraClickerDelegate extends WatchUi.BehaviorDelegate {

    private var _communicationManager as CommunicationManager?;
    private var _view as CameraClickerView?;

    /**
     * Initialize the input delegate
     * @param commManager The communication manager instance
     */
    function initialize(commManager as CommunicationManager?) {
        BehaviorDelegate.initialize();
        _communicationManager = commManager;
    }

    /**
     * Set the view reference for UI updates
     * @param view The main view instance
     */
    function setView(view as CameraClickerView) as Void {
        _view = view;
    }

    /**
     * Handle the select button (main action button)
     * Triggers photo capture
     * @return true if handled
     */
    function onSelect() as Boolean {
        return triggerCapture();
    }

    /**
     * Handle the menu button
     * Shows settings or additional options
     * @return true if handled
     */
    function onMenu() as Boolean {
        // For now, toggle flash mode
        if (_view != null) {
            _view.toggleFlash();
            WatchUi.requestUpdate();
        }
        return true;
    }

    /**
     * Handle the back button
     * Switch between cameras or exit
     * @return true if handled
     */
    function onBack() as Boolean {
        if (_view != null) {
            _view.toggleCamera();
            WatchUi.requestUpdate();
            
            // Send camera switch command to phone
            if (_communicationManager != null) {
                var cameraType = _view.getCurrentCamera();
                var cameraString = (cameraType == CameraClickerView.CAMERA_REAR) ? "rear" : "front";
                _communicationManager.sendCameraSwitchCommand(cameraString);
            }
        }
        return true;
    }

    /**
     * Handle touch screen tap events
     * @param clickEvent The click event information
     * @return true if handled
     */
    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        
        // Get screen dimensions
        var deviceSettings = System.getDeviceSettings();
        var screenWidth = deviceSettings.screenWidth;
        var screenHeight = deviceSettings.screenHeight;
        var centerX = screenWidth / 2;
        var centerY = screenHeight / 2;

        // Check if tap is on main capture button (center circle)
        var distance = Math.sqrt(Math.pow(x - centerX, 2) + Math.pow(y - centerY, 2));
        if (distance <= 60) { // BUTTON_RADIUS from view
            return triggerCapture();
        }

        // Check if tap is on left side (camera switch)
        if (x < screenWidth / 3) {
            if (_view != null) {
                _view.toggleCamera();
                WatchUi.requestUpdate();
                
                // Send camera switch command to phone
                if (_communicationManager != null) {
                    var cameraType = _view.getCurrentCamera();
                    var cameraString = (cameraType == CameraClickerView.CAMERA_REAR) ? "rear" : "front";
                    _communicationManager.sendCameraSwitchCommand(cameraString);
                }
            }
            return true;
        }

        // Check if tap is on right side (flash toggle)
        if (x > (screenWidth * 2) / 3) {
            if (_view != null) {
                _view.toggleFlash();
                WatchUi.requestUpdate();
                
                // Send flash mode command to phone
                if (_communicationManager != null) {
                    var flashMode = _view.getFlashMode();
                    var flashString = "";
                    switch (flashMode) {
                        case CameraClickerView.FLASH_AUTO:
                            flashString = "auto";
                            break;
                        case CameraClickerView.FLASH_ON:
                            flashString = "on";
                            break;
                        case CameraClickerView.FLASH_OFF:
                            flashString = "off";
                            break;
                    }
                    _communicationManager.sendFlashModeCommand(flashString);
                }
            }
            return true;
        }

        return false;
    }

    /**
     * Handle swipe gestures
     * @param swipeEvent The swipe event information
     * @return true if handled
     */
    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Boolean {
        var direction = swipeEvent.getDirection();
        
        switch (direction) {
            case WatchUi.SWIPE_LEFT:
                // Swipe left to switch to front camera
                if (_view != null) {
                    _view.toggleCamera();
                    WatchUi.requestUpdate();
                    
                    if (_communicationManager != null) {
                        var cameraType = _view.getCurrentCamera();
                        var cameraString = (cameraType == CameraClickerView.CAMERA_REAR) ? "rear" : "front";
                        _communicationManager.sendCameraSwitchCommand(cameraString);
                    }
                }
                return true;
                
            case WatchUi.SWIPE_RIGHT:
                // Swipe right to switch to rear camera
                if (_view != null) {
                    _view.toggleCamera();
                    WatchUi.requestUpdate();
                    
                    if (_communicationManager != null) {
                        var cameraType = _view.getCurrentCamera();
                        var cameraString = (cameraType == CameraClickerView.CAMERA_REAR) ? "rear" : "front";
                        _communicationManager.sendCameraSwitchCommand(cameraString);
                    }
                }
                return true;
                
            case WatchUi.SWIPE_UP:
                // Swipe up to cycle flash mode
                if (_view != null) {
                    _view.toggleFlash();
                    WatchUi.requestUpdate();
                    
                    if (_communicationManager != null) {
                        var flashMode = _view.getFlashMode();
                        var flashString = "";
                        switch (flashMode) {
                            case CameraClickerView.FLASH_AUTO:
                                flashString = "auto";
                                break;
                            case CameraClickerView.FLASH_ON:
                                flashString = "on";
                                break;
                            case CameraClickerView.FLASH_OFF:
                                flashString = "off";
                                break;
                        }
                        _communicationManager.sendFlashModeCommand(flashString);
                    }
                }
                return true;
                
            case WatchUi.SWIPE_DOWN:
                // Swipe down to trigger capture
                return triggerCapture();
        }
        
        return false;
    }

    /**
     * Trigger photo capture
     * @return true if command was sent successfully
     */
    private function triggerCapture() as Boolean {
        if (_communicationManager != null && _view != null) {
            // Update UI to show capturing state
            _view.updateCameraStatus(CameraClickerView.CAMERA_CAPTURING);
            WatchUi.requestUpdate();
            
            // Get current settings
            var cameraType = _view.getCurrentCamera();
            var flashMode = _view.getFlashMode();
            
            var cameraString = (cameraType == CameraClickerView.CAMERA_REAR) ? "rear" : "front";
            var flashString = "";
            switch (flashMode) {
                case CameraClickerView.FLASH_AUTO:
                    flashString = "auto";
                    break;
                case CameraClickerView.FLASH_ON:
                    flashString = "on";
                    break;
                case CameraClickerView.FLASH_OFF:
                    flashString = "off";
                    break;
            }
            
            // Send capture command
            var success = _communicationManager.sendCaptureCommand(cameraString, flashString);
            
            if (!success) {
                // If sending failed, reset camera status
                _view.updateCameraStatus(CameraClickerView.CAMERA_ERROR);
                WatchUi.requestUpdate();
            }
            
            return success;
        }
        
        return false;
    }

    /**
     * Handle key press events
     * @param keyEvent The key event information
     * @return true if handled
     */
    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        
        switch (key) {
            case WatchUi.KEY_ENTER:
            case WatchUi.KEY_START:
                return triggerCapture();
                
            case WatchUi.KEY_ESC:
            case WatchUi.KEY_LAP:
                if (_view != null) {
                    _view.toggleCamera();
                    WatchUi.requestUpdate();
                }
                return true;
        }
        
        return false;
    }
}

