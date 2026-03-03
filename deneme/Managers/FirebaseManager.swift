
import Foundation
import FirebaseCore
import FirebaseRemoteConfig
import FirebaseAnalytics

final class FirebaseManager {
    static let shared = FirebaseManager()
    
    private let remoteConfig = RemoteConfig.remoteConfig()
   
    private(set) var premiumProductIds: [String] = []
    private(set) var coinProductIds: [String] = []
    
 
    private let fallbackPremiumIds: [String] = [
        "y",
        "y"
    ]
    
    private let fallbackCoinIds: [String] = [
        "0",
        "0",
        "0"
    ]
    

    private(set) var latestVersion: String?
    private(set) var appStoreUrl: String?
    
   
    var onRemoteConfigReady: (() -> Void)?
    
    private init() {
        setupRemoteConfig()
    }
    
    func configure() {
      
        fetchRemoteConfig()
    }
    
    private func setupRemoteConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        
    }
    
    func fetchRemoteConfig(completion: ((Bool) -> Void)? = nil) {
     
        remoteConfig.fetchAndActivate { [weak self] status, error in
            guard let self = self else { return }
         
            
            if status == .error {
              
                self.loadProductIdsFromDefaults()
                completion?(false)
                return
            }
            
          
            let premiumIdsString = self.remoteConfig.configValue(forKey: "premium_ids").stringValue ?? ""
            let parsedPremiumIds = premiumIdsString.split(separator: ",")
                .map { String($0).trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty && self.isValidProductId($0) }
            self.premiumProductIds = parsedPremiumIds.isEmpty ? self.fallbackPremiumIds : parsedPremiumIds
            print("💎 Premium IDs: \(self.premiumProductIds) (fallback: \(parsedPremiumIds.isEmpty))")
            
           
            let coinIdsString = self.remoteConfig.configValue(forKey: "coin_ids").stringValue ?? ""
            let parsedCoinIds = coinIdsString.split(separator: ",").map { 
                var id = String($0).trimmingCharacters(in: .whitespaces)
                // Typo düzeltme: "om." ile başlıyorsa "com." yap
                if id.hasPrefix("om.") && !id.hasPrefix("com.") {
                    id = "c" + id
                }
                return id
            }.filter { !$0.isEmpty && self.isValidProductId($0) }
            self.coinProductIds = parsedCoinIds.isEmpty ? self.fallbackCoinIds : parsedCoinIds
            print("🪙 Coin IDs: \(self.coinProductIds) (fallback: \(parsedCoinIds.isEmpty))")
            
          
            self.latestVersion = self.remoteConfig.configValue(forKey: "latest_version").stringValue
            self.appStoreUrl = self.remoteConfig.configValue(forKey: "app_store_url").stringValue
            print("📱 Latest version: \(self.latestVersion ?? "nil"), App Store URL: \(self.appStoreUrl ?? "nil")")
            
         
            self.onRemoteConfigReady?()
            
            completion?(true)
        }
    }
    
    private func loadProductIdsFromDefaults() {
       
        let premiumIdsString = remoteConfig.configValue(forKey: "premium_ids").stringValue ?? ""
        let parsedPremiumIds = premiumIdsString.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
     
        premiumProductIds = parsedPremiumIds.isEmpty ? fallbackPremiumIds : parsedPremiumIds
        
        let coinIdsString = remoteConfig.configValue(forKey: "coin_ids").stringValue ?? ""
        let parsedCoinIds = coinIdsString.split(separator: ",").map { 
            var id = String($0).trimmingCharacters(in: .whitespaces)
          
            if id.hasPrefix("om.") && !id.hasPrefix("com.") {
                id = "c" + id
            }
            return id
        }.filter { !$0.isEmpty }
        
      
        coinProductIds = parsedCoinIds.isEmpty ? fallbackCoinIds : parsedCoinIds
        
      
        onRemoteConfigReady?()
    }
    
    func getAllProductIds() -> [String] {
        return premiumProductIds + coinProductIds
    }
    

    private func isValidProductId(_ productId: String) -> Bool {
     
        let validPrefixes = ["com."]
        return validPrefixes.contains { productId.hasPrefix($0) }
    }
    
    func getGroqApiKey() -> String? {
        let configKey = remoteConfig.configValue(forKey: "gro").stringValue
      
        return configKey.isEmpty ? nil : configKey
    }
    
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
   
    func getCurrentAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
   
    func isUpdateRequired() -> Bool {
        guard let latest = latestVersion, !latest.isEmpty else { return false }
        let current = getCurrentAppVersion()
        
       
        return isVersion(current, lessThan: latest)
    }
    
   
    private func isVersion(_ v1: String, lessThan v2: String) -> Bool {
        let v1Components = v1.split(separator: ".").compactMap { Int($0) }
        let v2Components = v2.split(separator: ".").compactMap { Int($0) }
        
        let maxCount = max(v1Components.count, v2Components.count)
        
        for i in 0..<maxCount {
            let v1Value = i < v1Components.count ? v1Components[i] : 0
            let v2Value = i < v2Components.count ? v2Components[i] : 0
            
            if v1Value < v2Value {
                return true
            } else if v1Value > v2Value {
                return false
            }
          
        }
        
       
        return false
    }
}
