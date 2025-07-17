import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

/**
 * Communication Manager
 * Handles all Bluetooth communication with the Android companion app
 */
class CommunicationManager {

    private var _isConnected as Boolean = false;
    private var _lastMessageTime as Number = 0;
    private var _sequenceNumber as Number = 0;
    private var _pendingMessages as Array<Dictionary> = [];

    // Message type constants
    private const MSG_CAMERA_COMMAND = "CAMERA_COMMAND";
    private const MSG_STATUS_REQUEST = "STATUS_REQUEST";
    private const MSG_HEARTBEAT = "HEARTBEAT";

    // Command constants
    private const CMD_CAPTURE_PHOTO = "CAPTURE_PHOTO";
    private const CMD_SWITCH_CAMERA = "SWITCH_CAMERA";
    private const CMD_SET_FLASH = "SET_FLASH";
    private const CMD_GET_STATUS = "GET_STATUS";

    /**
     * Initialize the communication manager
     */
    function initialize() {
        _sequenceNumber = 0;
        _pendingMessages = [];
        _isConnected = false;
    }

    /**
     * Start the communication manager
     * Begins attempting to establish connection with phone app
     */
    function start() as Void {
        // Send initial status request to establish connection
        sendStatusRequest();
        
        // Start heartbeat timer
        startHeartbeat();
    }

    /**
     * Stop the communication manager
     * Cleans up connections and resources
     */
    function stop() as Void {
        _isConnected = false;
        _pendingMessages = [];
    }

    /**
     * Send a photo capture command to the phone
     * @param camera Camera type ("rear" or "front")
     * @param flash Flash mode ("auto", "on", or "off")
     * @return true if message was sent successfully
     */
    function sendCaptureCommand(camera as String, flash as String) as Boolean {
        var message = createMessage(MSG_CAMERA_COMMAND, {
            "command" => CMD_CAPTURE_PHOTO,
            "parameters" => {
                "camera" => camera,
                "flash" => flash,
                "quality" => "high"
            }
        });
        
        return sendMessage(message);
    }

    /**
     * Send a camera switch command to the phone
     * @param camera Camera type ("rear" or "front")
     * @return true if message was sent successfully
     */
    function sendCameraSwitchCommand(camera as String) as Boolean {
        var message = createMessage(MSG_CAMERA_COMMAND, {
            "command" => CMD_SWITCH_CAMERA,
            "parameters" => {
                "camera" => camera
            }
        });
        
        return sendMessage(message);
    }

    /**
     * Send a flash mode command to the phone
     * @param flash Flash mode ("auto", "on", or "off")
     * @return true if message was sent successfully
     */
    function sendFlashModeCommand(flash as String) as Boolean {
        var message = createMessage(MSG_CAMERA_COMMAND, {
            "command" => CMD_SET_FLASH,
            "parameters" => {
                "flash" => flash
            }
        });
        
        return sendMessage(message);
    }

    /**
     * Send a status request to the phone
     * @return true if message was sent successfully
     */
    function sendStatusRequest() as Boolean {
        var message = createMessage(MSG_STATUS_REQUEST, {
            "command" => CMD_GET_STATUS
        });
        
        return sendMessage(message);
    }

    /**
     * Handle incoming message from phone app
     * @param msg The received phone app message
     */
    function handlePhoneMessage(msg as Communications.PhoneAppMessage) as Void {
        var data = msg.data;
        
        if (data instanceof Dictionary) {
            var messageType = data.get("messageType");
            
            if (messageType != null) {
                _isConnected = true;
                _lastMessageTime = Time.now().value();
                
                // Handle different message types
                if (messageType.equals("STATUS_UPDATE")) {
                    handleStatusUpdate(data);
                } else if (messageType.equals("CAPTURE_RESULT")) {
                    handleCaptureResult(data);
                } else if (messageType.equals("ERROR")) {
                    handleError(data);
                } else if (messageType.equals("ACKNOWLEDGMENT")) {
                    handleAcknowledment(data);
                }
            }
        }
    }

    /**
     * Handle status update from phone
     * @param data Message data
     */
    private function handleStatusUpdate(data as Dictionary) as Void {
        var payload = data.get("payload");
        if (payload instanceof Dictionary) {
            // Status update received - connection is confirmed
            _isConnected = true;
        }
    }

    /**
     * Handle capture result from phone
     * @param data Message data
     */
    private function handleCaptureResult(data as Dictionary) as Void {
        var payload = data.get("payload");
        if (payload instanceof Dictionary) {
            var success = payload.get("success");
            if (success != null && success instanceof Boolean) {
                // Capture result received
                System.println("Capture result: " + success);
            }
        }
    }

    /**
     * Handle error message from phone
     * @param data Message data
     */
    private function handleError(data as Dictionary) as Void {
        var payload = data.get("payload");
        if (payload instanceof Dictionary) {
            var errorMessage = payload.get("message");
            if (errorMessage != null && errorMessage instanceof String) {
                System.println("Error from phone: " + errorMessage);
            }
        }
    }

    /**
     * Handle acknowledgment from phone
     * @param data Message data
     */
    private function handleAcknowledment(data as Dictionary) as Void {
        var sequenceNumber = data.get("sequenceNumber");
        if (sequenceNumber != null && sequenceNumber instanceof Number) {
            // Remove acknowledged message from pending list
            removePendingMessage(sequenceNumber);
        }
    }

    /**
     * Create a standardized message
     * @param messageType Type of message
     * @param payload Message payload
     * @return Formatted message dictionary
     */
    private function createMessage(messageType as String, payload as Dictionary) as Dictionary {
        _sequenceNumber++;
        
        return {
            "messageType" => messageType,
            "timestamp" => Time.now().value(),
            "sequenceNumber" => _sequenceNumber,
            "payload" => payload
        };
    }

    /**
     * Send a message to the phone app
     * @param message Message dictionary to send
     * @return true if message was sent successfully
     */
    private function sendMessage(message as Dictionary) as Boolean {
        try {
            var phoneMessage = new Communications.PhoneAppMessage();
            phoneMessage.data = message;
            
            // Add to pending messages for acknowledgment tracking
            _pendingMessages.add(message);
            
            // Attempt to transmit the message
            Communications.transmit(phoneMessage, {}, new MessageTransmissionCallback());
            
            return true;
        } catch (ex) {
            System.println("Failed to send message: " + ex.getErrorMessage());
            return false;
        }
    }

    /**
     * Remove a pending message by sequence number
     * @param sequenceNumber Sequence number of message to remove
     */
    private function removePendingMessage(sequenceNumber as Number) as Void {
        for (var i = _pendingMessages.size() - 1; i >= 0; i--) {
            var msg = _pendingMessages[i];
            if (msg instanceof Dictionary) {
                var msgSeq = msg.get("sequenceNumber");
                if (msgSeq != null && msgSeq.equals(sequenceNumber)) {
                    _pendingMessages.remove(msg);
                    break;
                }
            }
        }
    }

    /**
     * Start heartbeat mechanism to maintain connection
     */
    private function startHeartbeat() as Void {
        // Send periodic heartbeat messages
        var heartbeatMessage = createMessage(MSG_HEARTBEAT, {});
        sendMessage(heartbeatMessage);
    }

    /**
     * Check if currently connected to phone
     * @return true if connected
     */
    function isConnected() as Boolean {
        // Consider disconnected if no message received in last 30 seconds
        var currentTime = Time.now().value();
        if (_isConnected && (currentTime - _lastMessageTime) > 30) {
            _isConnected = false;
        }
        
        return _isConnected;
    }

    /**
     * Update settings from app preferences
     */
    function updateSettings() as Void {
        // Handle any settings updates if needed
        // This could include communication timeouts, retry counts, etc.
    }

    /**
     * Get connection status information
     * @return Dictionary with connection details
     */
    function getConnectionInfo() as Dictionary {
        return {
            "connected" => _isConnected,
            "lastMessageTime" => _lastMessageTime,
            "pendingMessages" => _pendingMessages.size()
        };
    }
}

/**
 * Message Transmission Callback
 * Handles the result of message transmission attempts
 */
class MessageTransmissionCallback extends Communications.ConnectionListener {

    /**
     * Called when message transmission is successful
     * @param data Response data
     */
    function onComplete(data as Object) as Void {
        System.println("Message sent successfully");
    }

    /**
     * Called when message transmission fails
     * @param error Error code
     */
    function onError(error as Number) as Void {
        System.println("Message transmission failed with error: " + error);
        
        // Handle specific error cases
        switch (error) {
            case Communications.BLE_CONNECTION_UNAVAILABLE:
                System.println("Bluetooth connection unavailable");
                break;
            case Communications.BLE_QUEUE_FULL:
                System.println("Message queue full");
                break;
            case Communications.BLE_REQUEST_TOO_LARGE:
                System.println("Message too large");
                break;
            default:
                System.println("Unknown transmission error");
                break;
        }
    }
}

