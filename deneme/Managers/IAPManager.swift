
import Combine
import Foundation
import StoreKit

@MainActor
final class IAPManager: ObservableObject {

    static let shared = IAPManager()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIds: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
  
    private var premiumIds: [String] { FirebaseManager.shared.premiumProductIds }
    private var coinIds: [String] { FirebaseManager.shared.coinProductIds }
    
   
    private let fallbackPremiumIds: [String] = [
        "",
        ""
    ]
    
    private let fallbackCoinIds: [String] = [
        "",
        "",
        ""
    ]
    
   
    private let coinProductMapping: [String: Int] = [
        ""
    ]

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        updateListenerTask = listenForTransactions()
        
       
        FirebaseManager.shared.onRemoteConfigReady = { [weak self] in
            Task { @MainActor in
                await self?.loadProducts()
                await self?.updatePurchasedState()
            }
        }
        
        
        if !FirebaseManager.shared.getAllProductIds().isEmpty {
            Task {
                await loadProducts()
                await updatePurchasedState()
            }
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        let ids = FirebaseManager.shared.getAllProductIds()
        guard !ids.isEmpty else {
           
            isLoading = false
            return
        }
      
        do {
            products = try await Product.products(for: Set(ids))
            print("✅ Loaded \(products.count) products")
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to load products: \(error.localizedDescription)")
            isLoading = false
        }
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                await updatePurchasedState()
                await applyPurchase(transaction)
                return true
            case .unverified:
                return false
            }
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func updatePurchasedState() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchased.insert(transaction.productID)
            }
        }
        purchasedProductIds = purchased
    }

    private func applyPurchase(_ transaction: Transaction) async {
        let productId = transaction.productID
        
       
        await sendTransactionToServer(transaction)
        
      
        if let coinAmount = coinProductMapping[productId] {
            CoinManager.shared.updateCoins(coinAmount)
           
        }
    }
    
   
  

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.updatePurchasedState()
                    await self.applyPurchase(transaction)
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let t):
            return t
        }
    }

    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    func premiumProducts() -> [Product] {
        products.filter { premiumIds.contains($0.id) }
    }

    func coinProducts() -> [Product] {
        products.filter { coinIds.contains($0.id) }
    }
    
    func getAllProductIds() -> [String] {
        return premiumIds + coinIds
    }
    
  
    func getYearlyPremiumId() -> String? {
       
        let yearlyIds = ["c"]
        return premiumIds.first { yearlyIds.contains($0) }
    }
    
  
    func getMonthlyPremiumId() -> String? {
      
        let monthlyIds = ["co"]
        return premiumIds.first { monthlyIds.contains($0) }
    }
    
  
    func getYearlyProduct() -> Product? {
        guard let id = getYearlyPremiumId() else { return nil }
        return product(for: id)
    }
    
  
    func getMonthlyProduct() -> Product? {
        guard let id = getMonthlyPremiumId() else { return nil }
        return product(for: id)
    }
    
    func getPremiumIds() -> [String] {
        return premiumIds
    }
    
    func getCoinIds() -> [String] {
        return coinIds
    }
}

enum StoreError: Error {
    case failedVerification
}
