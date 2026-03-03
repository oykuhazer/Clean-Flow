

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        
        if KeychainManager.shared.hasCompletedOnboarding {
         
            let rootVC = MainTabBarController()
            window.rootViewController = rootVC
        } else {
           
            let onboardingVC = OnboardingViewController()
            onboardingVC.onComplete = { [weak self] in
                self?.transitionToMainApp()
            }
            window.rootViewController = onboardingVC
        }
        
        window.makeKeyAndVisible()
        self.window = window
    }
    
    private func transitionToMainApp() {
        guard let window = self.window else { return }
        
       
        KeychainManager.shared.hasCompletedOnboarding = true
        
        let mainVC = MainTabBarController()
        window.rootViewController = mainVC
        window.makeKeyAndVisible()
        
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let premiumVC = PremiumViewController()
            premiumVC.modalPresentationStyle = .fullScreen
            mainVC.present(UINavigationController(rootViewController: premiumVC), animated: true)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
       
    }

    private var hasCheckedForUpdate = false
    
    func sceneDidBecomeActive(_ scene: UIScene) {
       
        checkForAppUpdate()
        
       
        Task {
            await PremiumManager.shared.refreshStatus()
        }
    }
    
    private func checkForAppUpdate() {
       
        guard !hasCheckedForUpdate else { return }
        hasCheckedForUpdate = true
        
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            if FirebaseManager.shared.isUpdateRequired() {
                self?.showUpdateAlert()
            }
        }
    }
    
    private func showUpdateAlert() {
        guard let rootVC = window?.rootViewController else { return }
        
  
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        
        CustomAlert.present(
            .updateAvailable,
            from: topVC,
            onPrimary: { [weak self] in
                self?.openAppStore()
            },
            onSecondary: nil
        )
    }
    
    private func openAppStore() {
        guard let urlString = FirebaseManager.shared.appStoreUrl,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    func sceneWillResignActive(_ scene: UIScene) {
      
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
       
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
      
    }


}

