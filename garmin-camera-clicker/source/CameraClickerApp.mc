import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Communications;

/**
 * Camera Clicker Application
 * Main application class that manages the lifecycle and initialization
 * of the camera remote control functionality for Garmin watches.
 */
class CameraClickerApp extends Application.AppBase {

    private var _mainView as CameraClickerView?;
    private var _communicationManager as CommunicationManager?;

    /**
     * Application initialization
     * Sets up communication manager and initializes the app state
     */
    function initialize() {
        AppBase.initialize();
        
        // Initialize communication manager for phone messaging
        _communicationManager = new CommunicationManager();
        
        // Register for phone app messages
        Communications.registerForPhoneAppMessages(method(:onPhoneAppMessage));
    }

    /**
     * Called when the application starts
     * @return Initial view for the application
     */
    function onStart(state as Dictionary?) as Void {
        // Start communication manager
        if (_communicationManager != null) {
            _communicationManager.start();
        }
    }

    /**
     * Called when the application stops
     * Clean up resources and connections
     */
    function onStop(state as Dictionary?) as Void {
        // Stop communication manager
        if (_communicationManager != null) {
            _communicationManager.stop();
        }
    }

    /**
     * Return the initial view of your application here
     * @return Array containing the view and input delegate
     */
    function getInitialView() as Array<Views or InputDelegates>? {
        _mainView = new CameraClickerView();
        var delegate = new CameraClickerDelegate(_communicationManager);
        return [_mainView, delegate] as Array<Views or InputDelegates>;
    }

    /**
     * Handle incoming messages from the phone app
     * @param msg The message received from the phone
     */
    function onPhoneAppMessage(msg as Communications.PhoneAppMessage) as Void {
        if (_communicationManager != null) {
            _communicationManager.handlePhoneMessage(msg);
        }
        
        // Update the view if it exists
        if (_mainView != null) {
            _mainView.updateFromMessage(msg);
            WatchUi.requestUpdate();
        }
    }

    /**
     * New app settings have been received. Override to take action when the Settings
     * have been changed or received.
     * @param settings The new settings
     */
    function onSettingsChanged() as Void {
        // Handle settings changes if needed
        if (_communicationManager != null) {
            _communicationManager.updateSettings();
        }
    }
}

