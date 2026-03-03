

import UIKit
import StoreKit

extension Notification.Name {
    static let appLanguageDidChange = Notification.Name("appLanguageDidChange")
}

final class SettingsViewController: UIViewController {

    
    static var scrollToThemeSection = false

    private let tabBarBottomInset: CGFloat = 88

    private var isPremium: Bool {
        get async {
            await PremiumManager.shared.isPremium
        }
    }
    
    private var isPremiumSync: Bool = false
    private var coinBalanceView: CoinBalanceView?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var themeSectionView: UIView?
    private var premiumBannerView: PremiumBannerView?
    private var membershipRow: SettingRowView?
    private var restoreNoteLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.settingsTitle
        view.backgroundColor = UIColor.systemGroupedBackground
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLanguage), name: .appLanguageDidChange, object: nil)
    }

    @objc private func refreshLanguage() {
        navigationItem.title = L10n.settingsTitle
     
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Self.scrollToThemeSection, let themeSectionView = themeSectionView {
            Self.scrollToThemeSection = false
            let rect = themeSectionView.convert(themeSectionView.bounds, to: scrollView)
            scrollView.scrollRectToVisible(rect.insetBy(dx: 0, dy: -40), animated: true)
        }
    }

    private func sectionHeader(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    private func wrapInSection(_ title: String, _ rows: [UIView]) -> UIStackView {
        let header = sectionHeader(title)
        let stack = UIStackView(arrangedSubviews: rows)
        stack.axis = .vertical
        stack.spacing = 8
        stack.layer.cornerRadius = 12
        stack.clipsToBounds = true
        stack.translatesAutoresizingMaskIntoConstraints = false

        let section = UIStackView(arrangedSubviews: [header, stack])
        section.axis = .vertical
        section.spacing = 8
        section.alignment = .fill
        section.translatesAutoresizingMaskIntoConstraints = false
        return section
    }

    private func setupUI() {
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarBottomInset, right: 0)
        scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarBottomInset, right: 0)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        var sections: [UIView] = []

      
        let coinBar = CoinBalanceView(style: .compact)
        coinBar.configure(balance: CoinManager.shared.coins, showBuyButton: true) { [weak self] in
            self?.coinShopTapped()
        }
        coinBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([coinBar.heightAnchor.constraint(equalToConstant: 52)])
        coinBalanceView = coinBar
        sections.append(coinBar)

        let premiumBanner = PremiumBannerView()
        premiumBanner.translatesAutoresizingMaskIntoConstraints = false
        premiumBanner.onTap = { [weak self] in self?.premiumBannerTapped() }
        premiumBanner.isHidden = isPremiumSync
        premiumBannerView = premiumBanner
        sections.append(premiumBanner)

    
        let themeSection = makeThemeSection()
        themeSection.translatesAutoresizingMaskIntoConstraints = false
        themeSectionView = themeSection
        sections.append(themeSection)

       
        let membershipStatus = isPremiumSync ? L10n.membershipStatusPro : L10n.membershipStatusFree
        let premiumRow = SettingRowView(icon: "diamond.fill", title: L10n.myPremiumService, subtitle: membershipStatus)
        premiumRow.onTap = { [weak self] in self?.premiumBannerTapped() }
        membershipRow = premiumRow
        let restoreRow = SettingRowView(icon: "arrow.clockwise", title: L10n.restoreMembership)
        restoreRow.onTap = { [weak self] in self?.restoreTapped() }
        
    
        let noteLabel = UILabel()
        noteLabel.text = L10n.alreadyPremiumNote
        noteLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        noteLabel.textColor = .secondaryLabel
        noteLabel.textAlignment = .center
        noteLabel.isHidden = !isPremiumSync
        restoreNoteLabel = noteLabel
        
        let membershipStack = UIStackView(arrangedSubviews: [premiumRow, restoreRow, noteLabel])
        membershipStack.axis = .vertical
        membershipStack.spacing = 8
        sections.append(wrapInSection(L10n.membership, [membershipStack]))

        let languageRow = SettingRowView(icon: "globe", title: L10n.setLanguage)
        languageRow.onTap = { [weak self] in self?.languageTapped() }
      
        sections.append(wrapInSection(L10n.generalSettings, [languageRow]))

     
        let encourageRow = SettingRowView(icon: "hand.thumbsup.fill", title: L10n.encourageUs)
        encourageRow.onTap = { [weak self] in self?.encourageTapped() }
        let contactRow = SettingRowView(icon: "bubble.left.fill", title: L10n.contactUs)
        contactRow.onTap = { [weak self] in self?.contactTapped() }
        sections.append(wrapInSection(L10n.support, [encourageRow, contactRow]))

     
        let privacyRow = SettingRowView(icon: "shield.fill", title: L10n.privacyPolicy)
        privacyRow.onTap = { [weak self] in self?.privacyPolicyTapped() }
        let termsRow = SettingRowView(icon: "doc.text.fill", title: L10n.termsOfUse)
        termsRow.onTap = { [weak self] in self?.termsTapped() }
        sections.append(wrapInSection(L10n.legal, [privacyRow, termsRow]))

        let rootStack = UIStackView(arrangedSubviews: sections)
        rootStack.axis = .vertical
        rootStack.alignment = .fill
        rootStack.distribution = .fill
        rootStack.spacing = 24
        rootStack.setCustomSpacing(16, after: coinBar)
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(rootStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: rootStack.heightAnchor, constant: 52),

            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    private func makeThemeSection() -> UIView {
        let header = sectionHeader(L10n.themeSelection)
        let themeIds: [(id: String, asset: String)] = [("default", "default")] + (1...8).map { ("\($0)", "\($0)") }
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        let flow = UIStackView()
        flow.axis = .vertical
        flow.spacing = 14
        flow.alignment = .fill

        let row1Ids = Array(themeIds.prefix(5))
        let row2Ids = Array(themeIds.dropFirst(5))
        let row1 = makeThemeRow(row1Ids)
        let row2 = makeThemeRow(row2Ids)
        flow.addArrangedSubview(row1)
        if !row2Ids.isEmpty {
            flow.addArrangedSubview(row2)
        }

        container.addSubview(flow)
        flow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            flow.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            flow.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            flow.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            flow.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 140)
        ])

        let section = UIStackView(arrangedSubviews: [header, container])
        section.axis = .vertical
        section.spacing = 8
        section.alignment = .fill
        return section
    }

    private func makeThemeRow(_ themeIds: [(id: String, asset: String)]) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 12
        let keychain = KeychainManager.shared
        for t in themeIds {
            let isUnlocked = t.id == "default" || keychain.isThemeUnlocked(themeId: t.id)
            let cell = ThemeIconCell(themeId: t.id, assetName: t.asset, isUnlocked: isUnlocked)
            cell.onTap = { [weak self] in
                let nowUnlocked = t.id == "default" || KeychainManager.shared.isThemeUnlocked(themeId: t.id)
                self?.themeCellTapped(themeId: t.id, isUnlocked: nowUnlocked)
            }
            row.addArrangedSubview(cell)
        }
        return row
    }

    private func themeCellTapped(themeId: String, isUnlocked: Bool) {
        if themeId != "default" && !isUnlocked {
            CustomAlert.present(.lockedTheme, from: self, onSingle: { [weak self] in
                // Temaları Gör -> Discover ekranına git
                self?.tabBarController?.selectedIndex = 2
            })
            return
        }
        selectTheme(themeId)
    }

    private func selectTheme(_ themeId: String) {
        let keychain = KeychainManager.shared
        if themeId != "default" && !keychain.isThemeUnlocked(themeId: themeId) {
            if CoinManager.shared.spendCoins(Economy.themeUnlock) {
                keychain.unlockTheme(themeId: themeId)
                ThemeManager.shared.currentThemeId = themeId
                coinBalanceView?.balance = CoinManager.shared.coins
                themeSectionView?.setNeedsLayout()
                NotificationCenter.default.post(name: .themeUnlocked, object: nil, userInfo: ["themeId": themeId])
                let assetName = themeId
                CustomAlert.present(.themeUnlocked(themeAssetName: assetName), from: self, onPrimary: { [weak self] in
                    self?.themeSectionView?.setNeedsLayout()
                }, onSecondary: { [weak self] in
                    self?.themeSectionView?.setNeedsLayout()
                })
            }
            return
        }
        ThemeManager.shared.currentThemeId = themeId
        view.backgroundColor = UIColor.systemGroupedBackground
        themeSectionView?.setNeedsLayout()
    }

 

    private func premiumBannerTapped() {
       
        guard !isPremiumSync else { return }
        
        let vc = PremiumViewController()
        vc.onDismiss = { [weak self] in
            self?.view.setNeedsLayout()
            self?.updatePremiumUI()
        }
        vc.onPurchaseSuccess = { [weak self] in
            Self.scrollToThemeSection = true
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    private func coinShopTapped() {
        let shop = CoinShopViewController()
        let nav = UINavigationController(rootViewController: shop)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func restoreTapped() {
        Task {
            await IAPManager.shared.restorePurchases()
            await PremiumManager.shared.refreshStatus()
            let premium = await PremiumManager.shared.isPremium
            await MainActor.run {
                self.isPremiumSync = premium
                self.updatePremiumUI()
                self.updateRestoreNoteVisibility()
            }
        }
    }

    private func languageTapped() {
        
        let alert = UIAlertController(title: L10n.setLanguage, message: nil, preferredStyle: .actionSheet)
        for code in ["en", "de", "es", "pt", "fr", "zh", "ar"] {
            alert.addAction(UIAlertAction(title: code.uppercased(), style: .default) { _ in
                KeychainManager.shared.languageCode = code
                Self.notifyLanguageDidChange()
            })
        }
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
        present(alert, animated: true)
    }

    private static func notifyLanguageDidChange() {
        NotificationCenter.default.post(name: .appLanguageDidChange, object: nil)
    }

   

    private func encourageTapped() {
        
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func contactTapped() {
        let contactVC = ContactViewController(presenter: self) {
            // Dismiss callback - nothing needed here
        }
        present(contactVC, animated: true)
    }

    private func privacyPolicyTapped() {
        let vc = PolicyViewController(type: .privacy)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func termsTapped() {
        let vc = PolicyViewController(type: .terms)
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coinBalanceView?.balance = CoinManager.shared.coins
        Task {
            await PremiumManager.shared.refreshStatus()
            let premium = await PremiumManager.shared.isPremium
            await MainActor.run {
                self.isPremiumSync = premium
                self.updatePremiumUI()
            }
        }
    }

    private func updatePremiumUI() {
        let premium = isPremiumSync
        premiumBannerView?.isHidden = premium
        membershipRow?.updateSubtitle(premium ? L10n.membershipStatusPro : L10n.membershipStatusFree)
        updateRestoreNoteVisibility()
    }
    
    private func updateRestoreNoteVisibility() {
        restoreNoteLabel?.isHidden = !isPremiumSync
    }
}



private final class ThemeIconCell: UIView {
    var onTap: (() -> Void)?

    private let imageView = UIImageView()
    private let themeId: String
    private let lockOverlay = UIView()
    private let lockIcon = UIImageView(image: UIImage(systemName: "lock.fill"))

    init(themeId: String, assetName: String, isUnlocked: Bool) {
        self.themeId = themeId
        super.init(frame: .zero)
        imageView.image = UIImage(named: assetName)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 22
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.tertiarySystemFill
        addSubview(imageView)
        lockOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        lockOverlay.layer.cornerRadius = 22
        lockOverlay.translatesAutoresizingMaskIntoConstraints = false
        lockIcon.tintColor = .white
        lockIcon.contentMode = .scaleAspectFit
        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        lockOverlay.addSubview(lockIcon)
        addSubview(lockOverlay)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 56),
            lockOverlay.topAnchor.constraint(equalTo: imageView.topAnchor),
            lockOverlay.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            lockOverlay.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            lockOverlay.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            lockIcon.centerXAnchor.constraint(equalTo: lockOverlay.centerXAnchor),
            lockIcon.centerYAnchor.constraint(equalTo: lockOverlay.centerYAnchor),
            lockIcon.widthAnchor.constraint(equalToConstant: 18),
            lockIcon.heightAnchor.constraint(equalToConstant: 18)
        ])
        lockOverlay.isHidden = isUnlocked
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(themeUnlocked(_:)), name: .themeUnlocked, object: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func themeDidChange() {
        applySelectionBorder()
    }

    @objc private func themeUnlocked(_ notification: Notification) {
        guard let unlockedId = notification.userInfo?["themeId"] as? String, unlockedId == themeId else { return }
        lockOverlay.isHidden = true
    }

    private func applySelectionBorder() {
        let selected = ThemeManager.shared.currentThemeId == themeId
        imageView.layer.borderWidth = selected ? 3 : 0
        imageView.layer.borderColor = selected ? ThemeManager.shared.accentColor().cgColor : nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applySelectionBorder()
    }

    @objc private func tapped() {
        onTap?()
    }
}
