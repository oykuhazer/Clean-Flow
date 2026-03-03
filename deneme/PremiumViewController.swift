

import UIKit
import StoreKit

final class PremiumViewController: UIViewController {

    var onDismiss: (() -> Void)?
    var onPurchaseSuccess: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var selectedProduct: Product?
    private var yearlyCard: UIView?
    private var monthlyCard: UIView?
    private var headerImageView: UIImageView?

    private weak var premiumTitleLabel: UILabel?
    private weak var continueButton: UIButton?
    private weak var bullet1Title: UILabel?
    private weak var bullet1Sub: UILabel?
    private weak var bullet2Title: UILabel?
    private weak var bullet2Sub: UILabel?
    private weak var bullet3Title: UILabel?
    private weak var bullet3Sub: UILabel?
    private weak var closeButtonRef: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = ""
        navigationItem.rightBarButtonItem = nil
        setupLayout()
        loadProducts()
        
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            UIView.animate(withDuration: 0.3) {
                self?.closeButtonRef?.alpha = 1
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshLocalizedTexts()
        updatePricesFromStore()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyHeaderImageShadow()
    }

    private func applyHeaderImageShadow() {
        guard let imageView = headerImageView else { return }
        imageView.layer.mask = nil
        imageView.layer.shadowColor = nil
        imageView.layer.shadowOpacity = 0
    }

    private func refreshLocalizedTexts() {
        premiumTitleLabel?.text = L10n.premiumTitle
        continueButton?.setTitle(L10n.premiumContinue, for: .normal)
        bullet1Title?.text = L10n.premiumBullet1
        bullet1Sub?.text = L10n.premiumBullet1Sub
        bullet2Title?.text = L10n.premiumBullet2
        bullet2Sub?.text = L10n.premiumBullet2Sub
        bullet3Title?.text = L10n.premiumBullet3
        bullet3Sub?.text = L10n.premiumBullet3Sub
    }

    private func setupLayout() {
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemGroupedBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

       
        let imageHeight: CGFloat = 260
        let imageView = UIImageView(image: UIImage(named: "premium"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(red: 0.96, green: 0.45, blue: 0.45, alpha: 0.2)
        headerImageView = imageView

       
        let closeButton = UIButton(type: .system)
        let closeSize: CGFloat = 28
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)), for: .normal)
        closeButton.tintColor = UIColor.white.withAlphaComponent(0.9)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        closeButton.layer.cornerRadius = closeSize / 2
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.alpha = 0
        self.closeButtonRef = closeButton

     
        let titleLabel = UILabel()
        titleLabel.text = L10n.premiumTitle
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        premiumTitleLabel = titleLabel

        
        let (bullet1, b1t, b1s) = makeBulletWithRefs(title: L10n.premiumBullet1, subtitle: L10n.premiumBullet1Sub)
        bullet1Title = b1t
        bullet1Sub = b1s
        let (bullet2, b2t, b2s) = makeBulletWithRefs(title: L10n.premiumBullet2, subtitle: L10n.premiumBullet2Sub)
        bullet2Title = b2t
        bullet2Sub = b2s
        let (bullet3, b3t, b3s) = makeBulletWithRefs(title: L10n.premiumBullet3, subtitle: L10n.premiumBullet3Sub)
        bullet3Title = b3t
        bullet3Sub = b3s

        let bulletsStack = UIStackView(arrangedSubviews: [bullet1, bullet2, bullet3])
        bulletsStack.axis = .vertical
        bulletsStack.spacing = 20
        bulletsStack.alignment = .leading

        let textStack = UIStackView(arrangedSubviews: [titleLabel, bulletsStack])
        textStack.axis = .vertical
        textStack.spacing = 24
        textStack.setCustomSpacing(32, after: titleLabel)

        
        let yearlyCardView = makeSubscriptionCard(
            title: L10n.premiumYearly,
            price: "",
            pricePerWeek: "",
            isSelected: true,
            tag: 1
        )
        yearlyCard = yearlyCardView

        let monthlyCardView = makeSubscriptionCard(
            title: L10n.premiumMonthly,
            price: "",
            pricePerWeek: "",
            isSelected: false,
            tag: 0
        )
        monthlyCard = monthlyCardView

        let cardsStack = UIStackView(arrangedSubviews: [yearlyCardView, monthlyCardView])
        cardsStack.axis = .vertical
        cardsStack.spacing = 12
        cardsStack.alignment = .fill

       
        let btn = UIButton(type: .system)
        btn.setTitle(L10n.premiumContinue, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        btn.backgroundColor = ThemeManager.shared.accentColor()
        btn.layer.cornerRadius = 14
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        continueButton = btn

       
        let footerStack = makeFooterStack()
        let footerContainer = UIView()
        footerContainer.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.addSubview(footerStack)
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerStack.centerXAnchor.constraint(equalTo: footerContainer.centerXAnchor),
            footerStack.topAnchor.constraint(equalTo: footerContainer.topAnchor),
            footerStack.bottomAnchor.constraint(equalTo: footerContainer.bottomAnchor)
        ])

        let mainContentStack = UIStackView(arrangedSubviews: [textStack, cardsStack, btn, footerContainer])
        mainContentStack.axis = .vertical
        mainContentStack.spacing = 24
        mainContentStack.setCustomSpacing(20, after: textStack)
        mainContentStack.setCustomSpacing(16, after: btn)
        mainContentStack.alignment = .fill
        mainContentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        view.addSubview(closeButton)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainContentStack)

        let btnHeight: CGFloat = 52
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: imageHeight),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -30),
            closeButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: closeSize),
            closeButton.heightAnchor.constraint(equalToConstant: closeSize),

            scrollView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: mainContentStack.heightAnchor, constant: 32),

            mainContentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainContentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainContentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            btn.heightAnchor.constraint(equalToConstant: btnHeight)
        ])
        btn.layer.cornerRadius = btnHeight / 2
    }

    private func makeSubscriptionCard(
        title: String,
        price: String,
        pricePerWeek: String,
        isSelected: Bool,
        tag: Int
    ) -> UIView {
        let card = UIView()
        card.tag = tag
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 14
        card.layer.borderWidth = isSelected ? 2.5 : 1
        card.layer.borderColor = isSelected ? ThemeManager.shared.accentColor().cgColor : UIColor.separator.cgColor
        card.backgroundColor = isSelected ? ThemeManager.shared.accentColor().withAlphaComponent(0.08) : .secondarySystemGroupedBackground

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label

        let priceLabel = UILabel()
        priceLabel.text = price.isEmpty ? "—" : price
        priceLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        priceLabel.textColor = .label
        priceLabel.tag = 100

        let perWeekLabel = UILabel()
        perWeekLabel.text = pricePerWeek.isEmpty ? "" : pricePerWeek
        perWeekLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        perWeekLabel.textColor = .secondaryLabel
        perWeekLabel.tag = 102

        let leftStack = UIStackView(arrangedSubviews: [titleLabel, priceLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 2
        leftStack.alignment = .leading

        card.addSubview(leftStack)
        card.addSubview(perWeekLabel)
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        perWeekLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 72),
            leftStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            leftStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            leftStack.trailingAnchor.constraint(lessThanOrEqualTo: perWeekLabel.leadingAnchor, constant: -12),
            perWeekLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            perWeekLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14)
        ])

        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(subscriptionCardTapped(_:))))
        card.isUserInteractionEnabled = true
        return card
    }

    @objc private func subscriptionCardTapped(_ gesture: UIGestureRecognizer) {
        guard let card = gesture.view else { return }
        let isYearly = (card.tag == 1)
     
        selectedProduct = isYearly ? IAPManager.shared.getYearlyProduct() : IAPManager.shared.getMonthlyProduct()
        yearlyCard?.layer.borderColor = isYearly ? ThemeManager.shared.accentColor().cgColor : UIColor.separator.cgColor
        yearlyCard?.layer.borderWidth = isYearly ? 2.5 : 1
        yearlyCard?.backgroundColor = isYearly ? ThemeManager.shared.accentColor().withAlphaComponent(0.08) : .secondarySystemGroupedBackground
        monthlyCard?.layer.borderColor = !isYearly ? ThemeManager.shared.accentColor().cgColor : UIColor.separator.cgColor
        monthlyCard?.layer.borderWidth = !isYearly ? 2.5 : 1
        monthlyCard?.backgroundColor = !isYearly ? ThemeManager.shared.accentColor().withAlphaComponent(0.08) : .secondarySystemGroupedBackground
    }

    private func makeFooterStack() -> UIStackView {
        let terms = makeFooterButton(L10n.termsOfUse) { [weak self] in self?.openTerms() }
        let privacy = makeFooterButton(L10n.privacyPolicy) { [weak self] in self?.openPrivacy() }
        let restore = makeFooterButton(L10n.restore) { [weak self] in self?.restoreTapped() }
        let sep1 = makeFooterSeparator()
        let sep2 = makeFooterSeparator()
        let stack = UIStackView(arrangedSubviews: [terms, sep1, privacy, sep2, restore])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        stack.distribution = .fill
        terms.setContentHuggingPriority(.defaultLow, for: .horizontal)
        privacy.setContentHuggingPriority(.defaultLow, for: .horizontal)
        restore.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return stack
    }

    private func makeFooterSeparator() -> UIView {
        let line = UIView()
        line.backgroundColor = .separator
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.widthAnchor.constraint(equalToConstant: 1),
            line.heightAnchor.constraint(equalToConstant: 12)
        ])
        return line
    }

    private func makeFooterButton(_ title: String, action: @escaping () -> Void) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.secondaryLabel, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        btn.titleLabel?.numberOfLines = 1
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return btn
    }

    private func openTerms() {
        let vc = PolicyViewController(type: .terms)
        present(UINavigationController(rootViewController: vc), animated: true)
    }

    private func openPrivacy() {
        let vc = PolicyViewController(type: .privacy)
        present(UINavigationController(rootViewController: vc), animated: true)
    }

    private func restoreTapped() {
        Task {
            await IAPManager.shared.restorePurchases()
            await PremiumManager.shared.refreshStatus()
            let isPremium = await PremiumManager.shared.isPremium
            if isPremium {
                dismiss(animated: true) { [weak self] in self?.onDismiss?() }
            }
        }
    }

    private func updatePricesFromStore() {
       
        let yearlyProduct = IAPManager.shared.getYearlyProduct()
        let monthlyProduct = IAPManager.shared.getMonthlyProduct()
        if let yearly = yearlyProduct {
            selectedProduct = yearly
            updateCardPrice(card: yearlyCard, product: yearly, weeksInPeriod: 52)
        }
        if let monthly = monthlyProduct {
            if selectedProduct == nil { selectedProduct = monthly }
            updateCardPrice(card: monthlyCard, product: monthly, weeksInPeriod: 4)
        }
    }

    private func updateCardPrice(card: UIView?, product: Product, weeksInPeriod: Int) {
        guard let card = card else { return }
        let priceLabel = card.viewWithTag(100) as? UILabel
        let perWeekLabel = card.viewWithTag(102) as? UILabel
        priceLabel?.text = product.displayPrice
        let perWeekValue = (product.price as NSDecimalNumber).doubleValue / Double(weeksInPeriod)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let perWeekStr = formatter.string(from: NSNumber(value: perWeekValue)) ?? String(format: "%.2f", perWeekValue)
        perWeekLabel?.text = perWeekStr + "/WK"
    }

   
    private func makeBulletWithRefs(title: String, subtitle: String) -> (UIView, UILabel, UILabel) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let checkIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkIcon.tintColor = ThemeManager.shared.accentColor()
        checkIcon.contentMode = .scaleAspectFit
        checkIcon.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        let subLabel = UILabel()
        subLabel.text = subtitle
        subLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subLabel.textColor = .secondaryLabel
        subLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading
        textStack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(checkIcon)
        container.addSubview(textStack)
        NSLayoutConstraint.activate([
            checkIcon.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            checkIcon.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            checkIcon.widthAnchor.constraint(equalToConstant: 24),
            checkIcon.heightAnchor.constraint(equalToConstant: 24),
            textStack.leadingAnchor.constraint(equalTo: checkIcon.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textStack.topAnchor.constraint(equalTo: container.topAnchor),
            textStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return (container, titleLabel, subLabel)
    }

    private func loadProducts() {
        Task {
            await IAPManager.shared.loadProducts()
            await MainActor.run {
                updatePricesFromStore()
            }
        }
    }

    @objc private func continueTapped() {
       
        let product = selectedProduct ?? IAPManager.shared.getYearlyProduct() ?? IAPManager.shared.getMonthlyProduct()
        guard let product else {
            showPurchaseError(message: L10n.purchaseErrorNoProduct)
            return
        }
        Task {
            do {
                let success = try await IAPManager.shared.purchase(product)
                if success {
                    await PremiumManager.shared.refreshStatus()
                    let isPremium = await PremiumManager.shared.isPremium
                    if isPremium {
                        showPurchaseSuccess()
                    } else {
                        showPurchaseError(message: L10n.purchaseErrorVerification)
                    }
                }
            } catch {
                showPurchaseError(message: error.localizedDescription)
            }
        }
    }

    private func showPurchaseSuccess() {
        CustomAlert.present(.premiumActivation, from: self, onSingle: { [weak self] in
            self?.dismiss(animated: true) {
                self?.onDismiss?()
                self?.onPurchaseSuccess?()
            }
        })
    }
    
    private func showPurchaseError(message: String) {
        let alert = UIAlertController(title: L10n.purchaseErrorTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.ok, style: .default))
        present(alert, animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true) { [weak self] in self?.onDismiss?() }
    }
}
