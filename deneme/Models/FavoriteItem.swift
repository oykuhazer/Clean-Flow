

import Foundation
import SwiftData

@Model
final class FavoriteItem {
    @Attribute(.unique) var id: UUID
    var content: String
    var category: String
    var createdAt: Date
    
    init(content: String, category: String) {
        self.id = UUID()
        self.content = content
        self.category = category
        self.createdAt = Date()
    }
    
    var creationType: CreationType? {
        CreationType(rawValue: category)
    }
}
