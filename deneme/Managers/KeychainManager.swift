
import Foundation
import Security

final class KeychainManager {

    static let shared = KeychainManager()

    private let serviceName = Bundle.main.bundleIdentifier ?? ""

    private enum Key: String, CaseIterable {
        case coins
        case selectedThemeId
        case languageCode
        case unlockedThemeIds
        case isPremium
        case hasCompletedOnboarding
        case hasRequestedReview
        case hasCreatedFirstContent
        case hasChangedFirstTheme
        case hasAddedFirstFavorite
        case hasUsedFirstTrialGeneration
        case spamGenerationCount
        case spamLockEndTime
    }

    private init() {}

   

    private func setString(_ value: String, for key: Key) {
        guard let data = value.data(using: .utf8) else { return }
        delete(key: key)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private func string(for key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(key: Key) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }

 

    var coins: Int {
        get {
            guard let s = string(for: .coins), let v = Int(s) else { return 0 }
            return max(0, v)
        }
        set {
            setString("\(max(0, newValue))", for: .coins)
        }
    }

    

    var selectedThemeId: String {
        get {
            string(for: .selectedThemeId) ?? "default"
        }
        set {
            setString(newValue, for: .selectedThemeId)
        }
    }

   

    var languageCode: String {
        get {
            string(for: .languageCode) ?? "en"
        }
        set {
            setString(newValue, for: .languageCode)
        }
    }

  

    var unlockedThemeIds: Set<String> {
        get {
            guard let s = string(for: .unlockedThemeIds), !s.isEmpty else { return [] }
            return Set(s.split(separator: ",").map { String($0) })
        }
        set {
            setString(newValue.sorted().joined(separator: ","), for: .unlockedThemeIds)
        }
    }

    func isThemeUnlocked(themeId: String) -> Bool {
        if themeId == "default" { return true }
        return unlockedThemeIds.contains(themeId)
    }

    func unlockTheme(themeId: String) {
        guard themeId != "default" else { return }
        var set = unlockedThemeIds
        set.insert(themeId)
        unlockedThemeIds = set
    }

    
    @available(*, deprecated, message: "Use PremiumManager.shared.isPremium instead. Premium state should not be stored in Keychain.")
    var isPremium: Bool {
        get {
          
            return false
        }
        set {
           
        }
    }
   
    @available(*, deprecated, message: "Premium status is no longer stored in Keychain")
    func clearPremiumStatus() {
        delete(key: .isPremium)
        print("🧹 Premium status cleared from Keychain (deprecated)")
    }
    
   
    var hasCompletedOnboarding: Bool {
        get { string(for: .hasCompletedOnboarding) == "1" }
        set { setString(newValue ? "1" : "0", for: .hasCompletedOnboarding) }
    }
    
   
    var hasRequestedReview: Bool {
        get { string(for: .hasRequestedReview) == "1" }
        set { setString(newValue ? "1" : "0", for: .hasRequestedReview) }
    }
    
    var hasCreatedFirstContent: Bool {
        get { string(for: .hasCreatedFirstContent) == "1" }
        set { setString(newValue ? "1" : "0", for: .hasCreatedFirstContent) }
    }
    
    var hasChangedFirstTheme: Bool {
        get { string(for: .hasChangedFirstTheme) == "1" }
        set { setString(newValue ? "1" : "0", for: .hasChangedFirstTheme) }
    }
    
    var hasAddedFirstFavorite: Bool {
        get { string(for: .hasAddedFirstFavorite) == "1" }
        set { setString(newValue ? "1" : "0", for: .hasAddedFirstFavorite) }
    }
    
   
    
    var hasUsedFirstTrialGeneration: Bool {
        get { string(for: .hasUsedFirstTrialGeneration) == "1" }
        set { setString(newValue ? "1" : "0", for: .hasUsedFirstTrialGeneration) }
    }
    
  
    var spamGenerationCount: Int {
        get {
            guard let s = string(for: .spamGenerationCount), let v = Int(s) else { return 0 }
            return max(0, min(v, 100))
        }
        set {
            let clamped = max(0, min(newValue, 100))
            setString("\(clamped)", for: .spamGenerationCount)
        }
    }
    
    var spamLockEndTime: Date? {
        get {
            guard let s = string(for: .spamLockEndTime), let timestamp = Double(s) else { return nil }
            return Date(timeIntervalSince1970: timestamp)
        }
        set {
            if let date = newValue {
                setString("\(date.timeIntervalSince1970)", for: .spamLockEndTime)
            } else {
                delete(key: .spamLockEndTime)
            }
        }
    }
    
    func resetSpamCounter() {
        spamGenerationCount = 0
        spamLockEndTime = nil
    }
    
   
    
    func resetAllData() {
        for key in Key.allCases {
            delete(key: key)
        }
      
    }
}
