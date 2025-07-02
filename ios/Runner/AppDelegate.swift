import Flutter
import UIKit
import Firebase
import FirebaseAuth

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Register Flutter plugins
        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Handle deep links
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        print("🔗 Deep link received: \(url.absoluteString)")
        
        // Handle Firebase Auth deep links
        if Auth.auth().canHandle(url) {
            print("🔥 Firebase Auth deep link detected")
            return Auth.auth().canHandle(url)
        }
        
        // Let Flutter handle other deep links
        return super.application(app, open: url, options: options)
    }
}