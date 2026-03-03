

import StoreKit
import UIKit

final class AppReviewManager {
    
    static let shared = AppReviewManager()
    
    private init() {}
    

    
    func trackFirstContentCreated() {
        guard !KeychainManager.shared.hasCreatedFirstContent else { return }
        KeychainManager.shared.hasCreatedFirstContent = true
        requestReviewIfEligible()
    }
    
    func trackFirstThemeChanged() {
        guard !KeychainManager.shared.hasChangedFirstTheme else { return }
        KeychainManager.shared.hasChangedFirstTheme = true
        requestReviewIfEligible()
    }
    
    func trackFirstFavoriteAdded() {
        guard !KeychainManager.shared.hasAddedFirstFavorite else { return }
        KeychainManager.shared.hasAddedFirstFavorite = true
        requestReviewIfEligible()
    }
    
 
    func markReviewCompleted() {
        KeychainManager.shared.hasRequestedReview = true
    }
    

    
    private func requestReviewIfEligible() {
      
        guard !KeychainManager.shared.hasRequestedReview else { return }
        
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }) {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
}
