
import Foundation
import SwiftData

@MainActor
final class FavoriteManager {
    static let shared = FavoriteManager()
    
    private var container: ModelContainer?
    private var context: ModelContext?
    
    private init() {
        setupContainer()
    }
    
    private func setupContainer() {
        do {
            let schema = Schema([FavoriteItem.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
            if let container = container {
                context = ModelContext(container)
            }
        } catch {
            print("❌ FavoriteManager: Failed to create container: \(error)")
        }
    }
    
    
    func addFavorite(content: String, category: CreationType) {
        guard let context = context else { return }
        let item = FavoriteItem(content: content, category: category.rawValue)
        context.insert(item)
        save()
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
        
      
        AppReviewManager.shared.trackFirstFavoriteAdded()
    }
    
    func removeFavorite(_ item: FavoriteItem) {
        guard let context = context else { return }
        context.delete(item)
        save()
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
    
    func removeFavorites(_ items: [FavoriteItem]) {
        guard let context = context else { return }
        for item in items {
            context.delete(item)
        }
        save()
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
    
    func fetchAll() -> [FavoriteItem] {
        guard let context = context else { return [] }
        let descriptor = FetchDescriptor<FavoriteItem>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ FavoriteManager: Failed to fetch: \(error)")
            return []
        }
    }
    
    func fetchByCategory(_ category: CreationType) -> [FavoriteItem] {
        guard let context = context else { return [] }
        let categoryString = category.rawValue
        let predicate = #Predicate<FavoriteItem> { $0.category == categoryString }
        let descriptor = FetchDescriptor<FavoriteItem>(predicate: predicate, sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ FavoriteManager: Failed to fetch by category: \(error)")
            return []
        }
    }
    
    func isFavorite(content: String) -> Bool {
        guard let context = context else { return false }
        let predicate = #Predicate<FavoriteItem> { $0.content == content }
        let descriptor = FetchDescriptor<FavoriteItem>(predicate: predicate)
        do {
            let results = try context.fetch(descriptor)
            return !results.isEmpty
        } catch {
            return false
        }
    }
    
    func toggleFavorite(content: String, category: CreationType) -> Bool {
        guard let context = context else { return false }
        let predicate = #Predicate<FavoriteItem> { $0.content == content }
        let descriptor = FetchDescriptor<FavoriteItem>(predicate: predicate)
        do {
            let results = try context.fetch(descriptor)
            if let existing = results.first {
                context.delete(existing)
                save()
                NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
                return false
            } else {
                let item = FavoriteItem(content: content, category: category.rawValue)
                context.insert(item)
                save()
                NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
                return true
            }
        } catch {
            return false
        }
    }
    
    private func save() {
        guard let context = context else { return }
        do {
            try context.save()
        } catch {
            print("❌ FavoriteManager: Failed to save: \(error)")
        }
    }
    
    func clearAll() {
        guard let context = context else { return }
        let items = fetchAll()
        for item in items {
            context.delete(item)
        }
        save()
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
        print("🧹 All favorites cleared")
    }
}


extension Notification.Name {
    static let favoritesDidChange = Notification.Name("favoritesDidChange")
}
