import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Communications;
import Toybox.Application;

/**
 * Camera Clicker View
 * Main user interface view that displays camera controls and status information
 */
class CameraClickerView extends WatchUi.View {

    private var _connectionStatus as ConnectionStatus = CONNECTION_DISCONNECTED;
    private var _cameraStatus as CameraStatus = CAMERA_READY;
    private var _currentCamera as CameraType = CAMERA_REAR;
    private var _flashMode as FlashMode = FLASH_AUTO;
    private var _lastMessage as String = "";

    // UI Layout constants
    private const BUTTON_RADIUS = 60;
    private const STATUS_HEIGHT = 30;
    private const MARGIN = 10;

    // Connection status enumeration
    enum ConnectionStatus {
        CONNECTION_DISCONNECTED,
        CONNECTION_CONNECTING,
        CONNECTION_CONNECTED
    }

    // Camera status enumeration
    enum CameraStatus {
        CAMERA_READY,
        CAMERA_CAPTURING,
        CAMERA_ERROR
    }

    // Camera type enumeration
    enum CameraType {
        CAMERA_REAR,
        CAMERA_FRONT
    }

    // Flash mode enumeration
    enum FlashMode {
        FLASH_AUTO,
        FLASH_ON,
        FLASH_OFF
    }

    /**
     * Initialize the view
     */
    function initialize() {
        View.initialize();
    }

    /**
     * Load your resources here
     * @param dc The drawing context
     */
    function onLayout(dc as Graphics.Dc) as Void {
        // Layout is handled dynamically in onUpdate
    }

    /**
     * Called when this View is brought to the foreground. Restore
     * the state of this View and prepare it to be shown. This includes
     * loading resources into memory.
     */
    function onShow() as Void {
        // View is being shown
    }

    /**
     * Update the view
     * @param dc The drawing context
     */
    function onUpdate(dc as Graphics.Dc) as Void {
        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        // Draw status bar at top
        drawStatusBar(dc, width);

        // Draw main capture button
        drawCaptureButton(dc, centerX, centerY);

        // Draw secondary controls
        drawSecondaryControls(dc, width, height);

        // Draw connection status
        drawConnectionStatus(dc, width, height);
    }

    /**
     * Draw the status bar showing current settings
     * @param dc The drawing context
     * @param width Screen width
     */
    private function drawStatusBar(dc as Graphics.Dc, width as Number) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Camera type indicator
        var cameraText = (_currentCamera == CAMERA_REAR) ? "REAR" : "FRONT";
        dc.drawText(MARGIN, MARGIN, Graphics.FONT_TINY, cameraText, Graphics.TEXT_JUSTIFY_LEFT);

        // Flash mode indicator
        var flashText = "";
        switch (_flashMode) {
            case FLASH_AUTO:
                flashText = "AUTO";
                break;
            case FLASH_ON:
                flashText = "ON";
                break;
            case FLASH_OFF:
                flashText = "OFF";
                break;
        }
        dc.drawText(width - MARGIN, MARGIN, Graphics.FONT_TINY, "FLASH: " + flashText, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    /**
     * Draw the main capture button
     * @param dc The drawing context
     * @param centerX Center X coordinate
     * @param centerY Center Y coordinate
     */
    private function drawCaptureButton(dc as Graphics.Dc, centerX as Number, centerY as Number) as Void {
        // Button color based on status
        var buttonColor = Graphics.COLOR_WHITE;
        var textColor = Graphics.COLOR_BLACK;
        
        if (_cameraStatus == CAMERA_CAPTURING) {
            buttonColor = Graphics.COLOR_YELLOW;
        } else if (_cameraStatus == CAMERA_ERROR || _connectionStatus == CONNECTION_DISCONNECTED) {
            buttonColor = Graphics.COLOR_RED;
            textColor = Graphics.COLOR_WHITE;
        } else if (_connectionStatus == CONNECTION_CONNECTED) {
            buttonColor = Graphics.COLOR_GREEN;
        }

        // Draw button circle
        dc.setColor(buttonColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, BUTTON_RADIUS);
        
        // Draw button border
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawCircle(centerX, centerY, BUTTON_RADIUS);

        // Draw button text
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        var buttonText = "";
        
        switch (_cameraStatus) {
            case CAMERA_READY:
                buttonText = "CAPTURE";
                break;
            case CAMERA_CAPTURING:
                buttonText = "...";
                break;
            case CAMERA_ERROR:
                buttonText = "ERROR";
                break;
        }

        dc.drawText(centerX, centerY - 10, Graphics.FONT_MEDIUM, buttonText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    /**
     * Draw secondary control indicators
     * @param dc The drawing context
     * @param width Screen width
     * @param height Screen height
     */
    private function drawSecondaryControls(dc as Graphics.Dc, width as Number, height as Number) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        
        // Draw camera switch indicator (left side)
        dc.drawText(MARGIN, height / 2, Graphics.FONT_TINY, "SWITCH\nCAMERA", Graphics.TEXT_JUSTIFY_LEFT);
        
        // Draw flash toggle indicator (right side)
        dc.drawText(width - MARGIN, height / 2, Graphics.FONT_TINY, "FLASH\nTOGGLE", Graphics.TEXT_JUSTIFY_RIGHT);
    }

    /**
     * Draw connection status at bottom
     * @param dc The drawing context
     * @param width Screen width
     * @param height Screen height
     */
    private function drawConnectionStatus(dc as Graphics.Dc, width as Number, height as Number) as Void {
        var statusText = "";
        var statusColor = Graphics.COLOR_WHITE;

        switch (_connectionStatus) {
            case CONNECTION_DISCONNECTED:
                statusText = "DISCONNECTED";
                statusColor = Graphics.COLOR_RED;
                break;
            case CONNECTION_CONNECTING:
                statusText = "CONNECTING...";
                statusColor = Graphics.COLOR_YELLOW;
                break;
            case CONNECTION_CONNECTED:
                statusText = "CONNECTED";
                statusColor = Graphics.COLOR_GREEN;
                break;
        }

        dc.setColor(statusColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height - STATUS_HEIGHT, Graphics.FONT_SMALL, statusText, Graphics.TEXT_JUSTIFY_CENTER);

        // Show last message if available
        if (_lastMessage.length() > 0) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height - 15, Graphics.FONT_TINY, _lastMessage, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    /**
     * Called when this View is removed from the screen. Save the
     * state of this View here. This includes freeing resources from
     * memory.
     */
    function onHide() as Void {
        // View is being hidden
    }

    /**
     * Update view based on received phone message
     * @param msg The message from the phone
     */
    function updateFromMessage(msg as Communications.PhoneAppMessage) as Void {
        var data = msg.data;
        
        if (data instanceof Dictionary) {
            var messageType = data.get("messageType");
            
            if (messageType != null && messageType.equals("STATUS_UPDATE")) {
                var payload = data.get("payload");
                if (payload instanceof Dictionary) {
                    // Update connection status
                    _connectionStatus = CONNECTION_CONNECTED;
                    
                    // Update camera status
                    var cameraReady = payload.get("cameraReady");
                    if (cameraReady != null && cameraReady instanceof Boolean) {
                        _cameraStatus = cameraReady ? CAMERA_READY : CAMERA_ERROR;
                    }
                    
                    // Update last message
                    var message = payload.get("message");
                    if (message != null && message instanceof String) {
                        _lastMessage = message;
                    }
                }
            } else if (messageType != null && messageType.equals("CAPTURE_RESULT")) {
                var payload = data.get("payload");
                if (payload instanceof Dictionary) {
                    var success = payload.get("success");
                    if (success != null && success instanceof Boolean) {
                        _cameraStatus = success ? CAMERA_READY : CAMERA_ERROR;
                        _lastMessage = success ? "Photo captured!" : "Capture failed";
                    }
                }
            }
        }
    }

    /**
     * Update connection status
     * @param status New connection status
     */
    function updateConnectionStatus(status as ConnectionStatus) as Void {
        _connectionStatus = status;
    }

    /**
     * Update camera status
     * @param status New camera status
     */
    function updateCameraStatus(status as CameraStatus) as Void {
        _cameraStatus = status;
    }

    /**
     * Toggle camera (front/rear)
     */
    function toggleCamera() as Void {
        _currentCamera = (_currentCamera == CAMERA_REAR) ? CAMERA_FRONT : CAMERA_REAR;
    }

    /**
     * Toggle flash mode
     */
    function toggleFlash() as Void {
        switch (_flashMode) {
            case FLASH_AUTO:
                _flashMode = FLASH_ON;
                break;
            case FLASH_ON:
                _flashMode = FLASH_OFF;
                break;
            case FLASH_OFF:
                _flashMode = FLASH_AUTO;
                break;
        }
    }

    /**
     * Get current camera type
     * @return Current camera type
     */
    function getCurrentCamera() as CameraType {
        return _currentCamera;
    }

    /**
     * Get current flash mode
     * @return Current flash mode
     */
    function getFlashMode() as FlashMode {
        return _flashMode;
    }
}

