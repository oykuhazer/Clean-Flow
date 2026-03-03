

import Foundation


enum Economy {
    static let kafiye = 3
    static let dörtlük = 6
    static let şiir = 8
    static let themeUnlock = 40
}

final class CoinManager {

    static let shared = CoinManager()

   
    var onCoinsDidChange: (() -> Void)?

   

    struct CoinPack: Identifiable {
        let id: String
        let coins: Int
        let titleKey: String
        let subtitleKey: String
        var priceLabel: String { "" }
    }

   
    private static let coinProductMapping: [String: Int] = [
        "com.i.coins.50": 50,
        "com.i.coins.250": 250,
        "com.i.coins.500": 500,
        "com.i.750": 750
    ]
    
    static var coinPackProductIds: [(id: String, coins: Int)] {
        
        let coinIds = FirebaseManager.shared.coinProductIds
        if !coinIds.isEmpty {
            return coinIds.compactMap { id -> (id: String, coins: Int)? in
              
                guard let coins = coinProductMapping[id] else { return nil }
                return (id, coins)
            }
        }
       
        return coinProductMapping.map { ($0.key, $0.value) }.sorted { $0.1 < $1.1 }
    }

    
    static let themeIds: [String] = ["1", "2", "3", "4", "5", "6", "7", "8"]
    static let themeUnlockPrice = Economy.themeUnlock

    

    var coins: Int {
        get { KeychainManager.shared.coins }
        set {
            KeychainManager.shared.coins = newValue
            onCoinsDidChange?()
        }
    }


    private static let maxCoins = 1_000_000
  
    func updateCoins(_ delta: Int) {
       
        if delta > 0 && SecurityUtils.isJailbroken() {
          
            return
        }
        
    
        let newValue = max(0, min(coins + delta, Self.maxCoins))
        coins = newValue
    }
    
   
    var isCoinOperationsBlocked: Bool {
        return SecurityUtils.isJailbroken()
    }
    
    func addCoins(_ amount: Int) {
        updateCoins(amount)
    }

    func spendCoins(_ amount: Int) -> Bool {
        guard amount <= coins else { return false }
        updateCoins(-amount)
        return true
    }

    func isThemeUnlocked(themeId: String) -> Bool {
        KeychainManager.shared.isThemeUnlocked(themeId: themeId)
    }

    func purchaseTheme(themeId: String) -> Bool {
        guard themeId != "default", !isThemeUnlocked(themeId: themeId) else { return false }
        guard spendCoins(Economy.themeUnlock) else { return false }
        KeychainManager.shared.unlockTheme(themeId: themeId)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .themeUnlocked, object: nil, userInfo: ["themeId": themeId])
        }
        return true
    }

    func priceForTheme(themeId: String) -> Int {
        themeId == "default" ? 0 : Economy.themeUnlock
    }

  
    static let discoverImageIds: [String] = ["1", "2", "3", "4", "5", "6", "7", "8"]
    static let discoverImagePrices: [String: Int] = Dictionary(uniqueKeysWithValues: themeIds.map { ($0, Economy.themeUnlock) })

    var ownedDiscoverIds: Set<String> {
        get {
            KeychainManager.shared.unlockedThemeIds
        }
        set {
            KeychainManager.shared.unlockedThemeIds = newValue
        }
    }

    func isOwned(discoverImageId: String) -> Bool {
        isThemeUnlocked(themeId: discoverImageId)
    }

    func purchaseDiscoverImage(id: String) -> Bool {
        purchaseTheme(themeId: id)
    }

    func price(forDiscoverImageId id: String) -> Int {
        priceForTheme(themeId: id)
    }

    private init() {}
}
