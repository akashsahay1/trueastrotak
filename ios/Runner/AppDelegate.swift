import Flutter
import UIKit
import Firebase
import OtplessBM

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
        
        // Handle OTPless deep links
        if Otpless.shared.isOtplessDeeplink(url: url) {
            print("📱 OTPless deep link detected")
            Task(priority: .userInitiated) {
                do {
                    await Otpless.shared.handleDeeplink(url)
                    print("✅ OTPless deep link handled successfully")
                } catch {
                    print("❌ Error handling OTPless deep link: \(error)")
                }
            }
            return true
        }
        
        // Let Flutter handle other deep links
        return super.application(app, open: url, options: options)
    }
}