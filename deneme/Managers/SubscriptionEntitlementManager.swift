

import Foundation
import StoreKit

@MainActor
final class SubscriptionEntitlementManager {
    static let shared = SubscriptionEntitlementManager()

    #if DEBUG
  
    static var debugForceNonPremium = false
    #endif

    private var updatesTask: Task<Void, Never>?

    private init() {}

    func start() {
       
        Task { await refreshPremiumStatusAndPrint() }

     
        updatesTask?.cancel()
        updatesTask = Task.detached(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                } catch {
                  
                }
                await self.refreshPremiumStatusAndPrint()
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }

   

    func refreshPremiumStatusAndPrint() async {
        #if DEBUG
      
        if Self.debugForceNonPremium {
          
            return
        }
        #endif

      
        await PremiumManager.shared.refreshStatus()
        let isPremium = await PremiumManager.shared.isPremium

        if isPremium {
           
        } else {
           
        }
    }

    private func currentSubscriptionStatus() async -> (isPremium: Bool, planDescription: String) {
        var bestPremiumTransaction: Transaction?

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard isPremiumProductId(transaction.productID) else { continue }

            if transaction.revocationDate != nil { continue }
            
           

            if let currentBest = bestPremiumTransaction {
                let bestExp = currentBest.expirationDate ?? .distantFuture
                let txExp = transaction.expirationDate ?? .distantFuture
                if txExp > bestExp {
                    bestPremiumTransaction = transaction
                }
            } else {
                bestPremiumTransaction = transaction
            }
        }

        if let tx = bestPremiumTransaction {
            let plan = planDescription(for: tx.productID)
            return (true, plan)
        }

       
        do {
            let premiumIds = FirebaseManager.shared.premiumProductIds
            guard !premiumIds.isEmpty else { return (false, "") }
            let products = try await Product.products(for: Set(premiumIds))

            for product in products {
                guard let subscription = product.subscription else { continue }
                let statuses = try await subscription.status

                if statuses.contains(where: { isActiveSubscriptionState($0.state) }) {
                    return (true, planDescription(for: product.id))
                }
            }
        } catch {
           
        }

        return (false, "")
    }

    private func isActiveSubscriptionState(_ state: Product.SubscriptionInfo.RenewalState) -> Bool {
        switch state {
        case .subscribed, .inGracePeriod, .inBillingRetryPeriod:
            return true
        default:
            return false
        }
    }

    private func isPremiumProductId(_ id: String) -> Bool {
        FirebaseManager.shared.premiumProductIds.contains(id)
    }

    private func planDescription(for productId: String) -> String {
      
        let monthlyIds = [""]
        let yearlyIds = [""]
        
        if monthlyIds.contains(productId) {
            return "Aylık"
        }
        if yearlyIds.contains(productId) {
            return "Yıllık"
        }
        return productId
    }

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let t):
            return t
        }
    }
}

