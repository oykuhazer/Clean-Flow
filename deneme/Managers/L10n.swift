
import Foundation

enum L10n {

  
    private static var currentBundle: Bundle {
        let code = KeychainManager.shared.languageCode
        let localeId: String
        switch code {
        case "zh": localeId = "zh-Hans"
        default:   localeId = code
        }
        guard let path = Bundle.main.path(forResource: localeId, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }

    private static func tr(_ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, tableName: nil, bundle: currentBundle, value: key, comment: "")
        return args.isEmpty ? format : String(format: format, arguments: args)
    }


    static var appName: String { tr("app_name") }
    static var ok: String { tr("ok") }
    static var close: String { tr("close") }
    static var cancel: String { tr("cancel") }
    static var buy: String { tr("buy") }
    static var restore: String { tr("restore") }

 
    static var tabHome: String { tr("tab_home") }
    static var tabHistory: String { tr("tab_history") }
    static var tabFavorites: String { tr("tab_favorites") }
    static var tabDiscover: String { tr("tab_discover") }
    static var tabSettings: String { tr("tab_settings") }

  
    static var premiumTitle: String { tr("premium_title") }
    static var premiumBullet1: String { tr("premium_bullet1") }
    static var premiumBullet1Sub: String { tr("premium_bullet1_sub") }
    static var premiumBullet2: String { tr("premium_bullet2") }
    static var premiumBullet2Sub: String { tr("premium_bullet2_sub") }
    static var premiumBullet3: String { tr("premium_bullet3") }
    static var premiumBullet3Sub: String { tr("premium_bullet3_sub") }
    static var premiumContinue: String { tr("premium_continue") }
    static var premiumYearly: String { tr("premium_yearly") }
    static var premiumMonthly: String { tr("premium_monthly") }
    static var premiumFreeTrialDays: String { tr("premium_free_trial_days") }

    static var settingsTitle: String { tr("settings_title") }
    static var membership: String { tr("membership") }
    static var myPremiumService: String { tr("my_premium_service") }
    static var membershipStatusFree: String { tr("membership_status_free") }
    static var membershipStatusPro: String { tr("membership_status_pro") }
    static var restoreMembership: String { tr("restore_membership") }
    static var alreadyPremiumNote: String { tr("already_premium_note") }
    static var generalSettings: String { tr("general_settings") }
    static var setLanguage: String { tr("set_language") }
    static var clearCache: String { tr("clear_cache") }
    static var support: String { tr("support") }
    static var encourageUs: String { tr("encourage_us") }
    static var contactUs: String { tr("contact_us") }
    static var account: String { tr("account") }
    static var deleteAccount: String { tr("delete_account") }
    static var legal: String { tr("legal") }
    static var privacyPolicy: String { tr("privacy_policy") }
    static var termsOfUse: String { tr("terms_of_use") }
    static var subscriptionTerms: String { tr("subscription_terms") }
    static var themeSelection: String { tr("theme_selection") }
    static var aboutTheApp: String { tr("about_the_app") }
    static var appInfo: String { tr("app_info") }
    static var rateApp: String { tr("rate_app") }
    static var tellFriends: String { tr("tell_friends") }

    static var purchaseSuccessTitle: String { tr("purchase_success_title") }
    static var seeThemes: String { tr("see_themes") }

   
    static var coinBalance: String { tr("coin_balance") }
    static var buyCoins: String { tr("buy_coins") }
    static var coins: String { tr("coins") }
    static var thankYou: String { tr("thank_you") }
    static var coinsAdded: String { tr("coins_added") }
    static func coinsAddedFormat(_ count: Int) -> String { tr("coins_added_format", count) }

  
    static var sendFeedback: String { tr("send_feedback") }

   
    static var alertPremiumTitle: String { tr("alert_premium_title") }
    static var alertPremiumMessage: String { tr("alert_premium_message") }
    static var alertPremiumButton: String { tr("alert_premium_button") }

    static var alertCoinSuccessTitle: String { tr("alert_coin_success_title") }
    static var alertCoinSuccessMessage: String { tr("alert_coin_success_message") }
    static var alertSeeThemes: String { tr("alert_see_themes") }
    static var alertStartCreating: String { tr("alert_start_creating") }

    static var alertThemeUnlockedTitle: String { tr("alert_theme_unlocked_title") }
    static var alertThemeUnlockedMessage: String { tr("alert_theme_unlocked_message") }
    static var alertApplyNow: String { tr("alert_apply_now") }

    static var alertFeedbackTitle: String { tr("alert_feedback_title") }
    static var alertFeedbackMessage: String { tr("alert_feedback_message") }

    static var alertInsufficientCoinsTitle: String { tr("alert_insufficient_coins_title") }
    static var alertInsufficientCoinsMessage: String { tr("alert_insufficient_coins_message") }
    static var alertGetCoins: String { tr("alert_get_coins") }
    static var alertReviewPremium: String { tr("alert_review_premium") }
    
    static var alertLockedThemeTitle: String { tr("alert_locked_theme_title") }
    static var alertLockedThemeMessage: String { tr("alert_locked_theme_message") }
    
    static var alertRateLimitTitle: String { tr("alert_rate_limit_title") }
    static var alertRateLimitMessage: String { tr("alert_rate_limit_message") }
    
    static var alertSpamLimitTitle: String { tr("alert_spam_limit_title") }
    static var alertSpamLimitMessage: String { tr("alert_spam_limit_message") }
    
    static var alertContactSuccessTitle: String { tr("alert_contact_success_title") }
    static var alertContactSuccessMessage: String { tr("alert_contact_success_message") }
    
    static var alertUpdateTitle: String { tr("alert_update_title") }
    static var alertUpdateMessage: String { tr("alert_update_message") }
    static var alertUpdateButton: String { tr("alert_update_button") }
    static var alertLater: String { tr("alert_later") }
    
   
    static var generating: String { tr("generating") }
    static var generationError: String { tr("generation_error") }
    static var typeYourMessage: String { tr("type_your_message") }
    static var chatWelcomeMessage: String { tr("chat_welcome_message") }
    static var selectType: String { tr("select_type") }
    static var whatToCreate: String { tr("what_to_create") }
    static var insufficientCoinsForGeneration: String { tr("insufficient_coins_for_generation") }
    
   
    static var favorites: String { tr("favorites") }
    static var noFavoritesYet: String { tr("no_favorites_yet") }
    static var noFavoritesSubtitle: String { tr("no_favorites_subtitle") }
    static var createNow: String { tr("create_now") }
    static var selectAll: String { tr("select_all") }
    static var deselectAll: String { tr("deselect_all") }
    static var edit: String { tr("edit") }
    static var done: String { tr("done") }
    static var delete: String { tr("delete") }
    static var copy: String { tr("copy") }
    

    static var onboardingWelcome: String { tr("onboarding_welcome") }
    static var onboardingAppDescription: String { tr("onboarding_app_description") }
    static var onboardingSelectLanguage: String { tr("onboarding_select_language") }
    static var onboardingAITitle: String { tr("onboarding_ai_title") }
    static var onboardingAISubtitle: String { tr("onboarding_ai_subtitle") }
    static var onboardingFeaturePoem: String { tr("onboarding_feature_poem") }
    static var onboardingFeatureQuatrain: String { tr("onboarding_feature_quatrain") }
    static var onboardingFeatureJoke: String { tr("onboarding_feature_joke") }
    static var onboardingFeatureRhyme: String { tr("onboarding_feature_rhyme") }
    static var onboardingThemesTitle: String { tr("onboarding_themes_title") }
    static var onboardingThemesSubtitle: String { tr("onboarding_themes_subtitle") }
    static var onboardingFavoritesTitle: String { tr("onboarding_favorites_title") }
    static var onboardingFavoritesSubtitle: String { tr("onboarding_favorites_subtitle") }
    static var onboardingShareTitle: String { tr("onboarding_share_title") }
    static var onboardingShareSubtitle: String { tr("onboarding_share_subtitle") }
    static var nextButton: String { tr("next_button") }
    static var getStarted: String { tr("get_started") }
    
  
    static var homeHello: String { tr("home_hello") }
    static var homeTitle: String { tr("home_title") }
    static var homeSubtitle: String { tr("home_subtitle") }
    
   
    static var feedbackTitle: String { tr("feedback_title") }
    static var feedbackPlaceholder: String { tr("feedback_placeholder") }
    static var feedbackRating: String { tr("feedback_rating") }
    static var feedbackThankYouTitle: String { tr("feedback_thank_you_title") }
    static var feedbackThankYouMessage: String { tr("feedback_thank_you_message") }
    

    static var specialOfferTitle: String { tr("special_offer_title") }
    static var specialOfferSubtitle: String { tr("special_offer_subtitle") }
    
   
    static var purchased: String { tr("purchased") }
    
  
    static var creationTypeRhyme: String { tr("creation_type_rhyme") }
    static var creationTypePoem: String { tr("creation_type_poem") }
    static var creationTypeQuatrain: String { tr("creation_type_quatrain") }
    static var creationTypeJoke: String { tr("creation_type_joke") }
    
  
    static var privacyPolicyContent: String { tr("privacy_policy_content") }
    static var termsOfUseContent: String { tr("terms_of_use_content") }
    
   
    static var purchaseErrorTitle: String { tr("purchase_error_title") }
    static var purchaseErrorNoProduct: String { tr("purchase_error_no_product") }
    static var purchaseErrorVerification: String { tr("purchase_error_verification") }
}
