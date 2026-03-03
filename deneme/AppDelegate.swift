
import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let projectId = plist["PROJECT_ID"] as? String,
              let bundleId = plist["BUNDLE_ID"] as? String else {
            print("⚠️ Firebase: GoogleService-Info.plist not found or invalid")
            return true
        }
        
    
        FirebaseApp.configure()
        FirebaseManager.shared.configure()

   
        SubscriptionEntitlementManager.shared.start()
        
     
        KeychainManager.shared.resetAllData()
      
        if CoinManager.shared.coins == 0 {
            CoinManager.shared.updateCoins(3)
        }
        
        return true
    }

 

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
     
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
       
    }


}

