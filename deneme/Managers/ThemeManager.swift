
import UIKit

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
    static let themeUnlocked = Notification.Name("themeUnlocked")
}

enum AppThemeId: String, CaseIterable {
    case `default` = "default"
    case blue = "1"
    case gray = "2"
    case pink = "3"
    case green = "4"
    case orange = "5"
    case yellow = "6"
    case red = "7"
    case purple = "8"

    var assetImageName: String {
        switch self {
        case .default: return "default"
        case .blue: return "1"
        case .gray: return "2"
        case .pink: return "3"
        case .green: return "4"
        case .orange: return "5"
        case .yellow: return "6"
        case .red: return "7"
        case .purple: return "8"
        }
    }

    var accentColor: UIColor {
        switch self {
        case .default: return UIColor(red: 0.55, green: 0.28, blue: 0.65, alpha: 1)
        case .blue: return UIColor(red: 0.25, green: 0.47, blue: 0.85, alpha: 1)
        case .gray: return UIColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1)
        case .pink: return UIColor(red: 0.91, green: 0.4, blue: 0.54, alpha: 1)
        case .green: return UIColor(red: 0.2, green: 0.68, blue: 0.42, alpha: 1)
        case .orange: return UIColor(red: 0.95, green: 0.55, blue: 0.2, alpha: 1)
        case .yellow: return UIColor(red: 0.95, green: 0.78, blue: 0.2, alpha: 1)
        case .red: return UIColor(red: 0.9, green: 0.25, blue: 0.25, alpha: 1)
        case .purple: return UIColor(red: 0.55, green: 0.35, blue: 0.78, alpha: 1)
        }
    }

    var secondaryColor: UIColor {
        accentColor.withAlphaComponent(0.85)
    }

    var lightTint: UIColor {
        accentColor.withAlphaComponent(0.25)
    }
}

final class ThemeManager {

    static let shared = ThemeManager()

    var currentThemeId: String {
        get { KeychainManager.shared.selectedThemeId }
        set {
            let oldValue = KeychainManager.shared.selectedThemeId
            KeychainManager.shared.selectedThemeId = newValue
            applyCurrentTheme()
            
           
            if oldValue != newValue {
                AppReviewManager.shared.trackFirstThemeChanged()
            }
        }
    }

    var currentTheme: AppThemeId {
        AppThemeId(rawValue: currentThemeId) ?? .default
    }

    var onThemeDidChange: (() -> Void)?

    private init() {
        applyCurrentTheme()
    }

    func applyCurrentTheme() {
        let theme = currentTheme
        DispatchQueue.main.async { [weak self] in
            if let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap(\.windows)
                .first(where: { $0.isKeyWindow }) {
                window.tintColor = theme.accentColor
            }
            self?.onThemeDidChange?()
            NotificationCenter.default.post(name: .themeDidChange, object: self)
        }
    }

    func accentColor() -> UIColor {
        currentTheme.accentColor
    }

    func secondaryColor() -> UIColor {
        currentTheme.secondaryColor
    }

    func lightTint() -> UIColor {
        currentTheme.lightTint
    }
}
