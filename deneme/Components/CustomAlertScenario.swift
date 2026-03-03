
import UIKit

enum CustomAlertScenario {
    case premiumActivation
    case coinPurchaseSuccess
    case themeUnlocked(themeAssetName: String)
    case feedbackSent
    case insufficientCoins
    case lockedTheme
    case rateLimitExceeded
    case spamLimitExceeded
    case contactSuccess
    case updateAvailable
}

enum CustomAlert {

 
    static func present(
        _ scenario: CustomAlertScenario,
        from presenter: UIViewController,
        onPrimary: (() -> Void)? = nil,
        onSecondary: (() -> Void)? = nil,
        onSingle: (() -> Void)? = nil
    ) {
        let (imageName, imageInCircle, imageTint, title, message, buttons): (String?, Bool, UIColor?, String, String, [CustomAlertButton]) = {
            switch scenario {
            case .premiumActivation:
                return ("premium", true, nil, L10n.alertPremiumTitle, L10n.alertPremiumMessage,
                    [CustomAlertButton(title: L10n.alertPremiumButton, isPrimary: true, action: onSingle)])
            case .coinPurchaseSuccess:
                return ("inapppurchase", true, nil, L10n.alertCoinSuccessTitle, L10n.alertCoinSuccessMessage,
                    [
                        CustomAlertButton(title: L10n.alertSeeThemes, isPrimary: true, action: onPrimary),
                        CustomAlertButton(title: L10n.alertStartCreating, isPrimary: false, action: onSecondary)
                    ])
            case .themeUnlocked(let assetName):
                return (assetName, true, nil, L10n.alertThemeUnlockedTitle, L10n.alertThemeUnlockedMessage,
                    [
                        CustomAlertButton(title: L10n.alertApplyNow, isPrimary: true, action: onPrimary),
                        CustomAlertButton(title: L10n.ok, isPrimary: false, action: onSecondary)
                    ])
            case .feedbackSent:
                return (nil, true, ThemeManager.shared.accentColor(), L10n.alertFeedbackTitle, L10n.alertFeedbackMessage,
                    [CustomAlertButton(title: L10n.ok, isPrimary: true, action: onSingle)])
            case .insufficientCoins:
                return (nil, true, UIColor.coinYellow, L10n.alertInsufficientCoinsTitle, L10n.alertInsufficientCoinsMessage,
                    [
                        CustomAlertButton(title: L10n.alertGetCoins, isPrimary: true, action: onPrimary),
                        CustomAlertButton(title: L10n.alertReviewPremium, isPrimary: false, action: onSecondary)
                    ])
            case .lockedTheme:
                return (nil, true, ThemeManager.shared.accentColor(), L10n.alertLockedThemeTitle, L10n.alertLockedThemeMessage,
                    [CustomAlertButton(title: L10n.alertSeeThemes, isPrimary: true, action: onSingle)])
            case .rateLimitExceeded:
                return (nil, true, ThemeManager.shared.accentColor(), L10n.alertRateLimitTitle, L10n.alertRateLimitMessage,
                    [CustomAlertButton(title: L10n.ok, isPrimary: true, action: onSingle)])
            case .spamLimitExceeded:
                return (nil, true, UIColor.systemOrange, L10n.alertSpamLimitTitle, L10n.alertSpamLimitMessage,
                    [CustomAlertButton(title: L10n.ok, isPrimary: true, action: onSingle)])
            case .contactSuccess:
                return (nil, true, ThemeManager.shared.accentColor(), L10n.alertContactSuccessTitle, L10n.alertContactSuccessMessage,
                    [CustomAlertButton(title: L10n.ok, isPrimary: true, action: onSingle)])
            case .updateAvailable:
                return (nil, true, ThemeManager.shared.accentColor(), L10n.alertUpdateTitle, L10n.alertUpdateMessage,
                    [
                        CustomAlertButton(title: L10n.alertUpdateButton, isPrimary: true, action: onPrimary),
                        CustomAlertButton(title: L10n.alertLater, isPrimary: false, action: onSecondary)
                    ])
            }
        }()

        let iconImage: UIImage?
        let config = UIImage.SymbolConfiguration(pointSize: 44, weight: .medium)
        switch scenario {
        case .feedbackSent, .contactSuccess:
            iconImage = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        case .insufficientCoins:
            iconImage = UIImage(systemName: "circle.inset.filled", withConfiguration: config)
        case .lockedTheme:
            iconImage = UIImage(systemName: "paintpalette.fill", withConfiguration: config)
        case .rateLimitExceeded:
            iconImage = UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: config)
        case .spamLimitExceeded:
            iconImage = UIImage(systemName: "clock.fill", withConfiguration: config)
        case .updateAvailable:
            iconImage = UIImage(systemName: "arrow.down.circle.fill", withConfiguration: config)
        default:
            iconImage = nil
        }

        let vc = CustomAlertViewController(
            image: iconImage,
            imageName: imageName,
            imageInCircle: imageInCircle,
            imageTintColor: imageTint,
            title: title,
            message: message,
            buttons: buttons,
            autoDismissAfter: nil
        )
        presenter.present(vc, animated: true)
    }
}
