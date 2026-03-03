

import Foundation
import StoreKit

actor PremiumManager {
    
    static let shared = PremiumManager()
    
    private(set) var isPremium: Bool = false
    
 
    private let fallbackPremiumIds: [String] = [
        "",
        ""
    ]
    
    private init() {}
    
   
    private func getPremiumProductIds() async -> [String] {
        let remoteIds = await MainActor.run { FirebaseManager.shared.premiumProductIds }
        return remoteIds.isEmpty ? fallbackPremiumIds : remoteIds
    }
    
   
    func refreshStatus() async {
        var hasPremium = false
        let validPremiumIds = await getPremiumProductIds()
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
               
                if validPremiumIds.contains(transaction.productID) {
                    hasPremium = true
                    break
                }
            }
        }
        
        isPremium = hasPremium
    }
}
