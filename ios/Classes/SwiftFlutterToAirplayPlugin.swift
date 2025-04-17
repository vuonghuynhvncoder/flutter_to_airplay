import Flutter
import AVKit
import UIKit

public class SwiftFlutterToAirplayPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftFlutterToAirplayPlugin()
        
        // Register widget
        registrar.register(
            SharePlatformViewFactory(messenger: registrar.messenger()),
            withId: "airplay_route_picker_view",
            gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicy(rawValue: 0))

        registrar.register(
            SharePlatformViewFactory(messenger: registrar.messenger()),
            withId: "flutter_avplayer_view",
            gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicy(rawValue: 0))
        
        //Method call
        registrar.addMethodCallDelegate(instance, channel: FlutterMethodChannel(name: "com.junaidrehmat.flutterToAirplay.airplay_channel", binaryMessenger: registrar.messenger()))
        
        // EventChannel to detect AirPlay status
        let airplayStatusChannel = FlutterEventChannel(name: "airplay_status_channel", binaryMessenger: registrar.messenger())
        airplayStatusChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "trigger_airplay" {
            triggerAirplayMenu()
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    func triggerAirplayMenu() {
        print("SwiftFlutterToAirplayPlugin::triggerAirplayMenu")
        DispatchQueue.main.async {
            let routePickerView = AVRoutePickerView()
            
            // Find and trigger the button inside AVRoutePickerView
            if let button = routePickerView.subviews.first(where: { $0 is UIButton }) as? UIButton {
                button.sendActions(for: .touchUpInside)
            }
        }
    }
    
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioRouteChanged),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        sendAirplayStatus()
        return nil
    }
    
    @objc func audioRouteChanged(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        sendAirplayStatus()
    }
    
    func sendAirplayStatus() {
        let session = AVAudioSession.sharedInstance()
        let airplay = session.currentRoute.outputs.first { item in
            item.portType == .airPlay
        }
        // Send AirPlay status to Flutter
        eventSink?(airplay?.toDict())
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        NotificationCenter.default.removeObserver(self)
        return nil
    }
}


extension AVAudioSessionPortDescription {
    func toDict() -> Dictionary<String, Any> {
        var dict = [String : Any]()
        dict["uid"] = self.uid
        dict["portName"] = self.portName
        return dict
    }
}
