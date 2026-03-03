
import UIKit
import StoreKit

final class CoinShopViewController: UIViewController {

    var onDismiss: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let manager = CoinManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.buyCoins
        view.backgroundColor = .clear
        view.insertSubview(BackgroundGradientView(frame: view.bounds), at: 0)
        if let sheet = navigationController?.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
        }
        if navigationController?.viewControllers.first == self, navigationController?.presentingViewController != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: L10n.close, style: .plain, target: self, action: #selector(closeTapped))
        }
        setupBalanceHeader()
        setupPackList()
        layoutContent()
        loadProductsAndUpdatePrices()
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
    }
    
    private func loadProductsAndUpdatePrices() {
        Task {
            await IAPManager.shared.loadProducts()
            await MainActor.run {
                updateAllPriceLabels()
            }
        }
    }
    
    private func updateAllPriceLabels() {
        let coinIds = FirebaseManager.shared.coinProductIds
        for (index, container) in packCardContainers.enumerated() {
            guard index < coinIds.count else { continue }
            let productId = coinIds[index]
          
            if let priceLabel = findPriceLabel(in: container) {
                if let product = IAPManager.shared.product(for: productId) {
                    priceLabel.text = product.displayPrice
                   
                } else {
                    priceLabel.text = ""
                  
                }
            }
        }
    }
    
    private func findPriceLabel(in view: UIView) -> UILabel? {
        for subview in view.subviews {
            if let label = subview as? UILabel, label.tag > 0 {
                return label
            }
            if let found = findPriceLabel(in: subview) {
                return found
            }
        }
        return nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func themeDidChange() {
        applyThemeToCards()
    }

    private var packCardContainers: [UIView] = []

    private func setupBalanceHeader() {
        let coinView = CoinBalanceView(style: .compact)
        coinView.configure(balance: manager.coins, showBuyButton: false)
        coinView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(coinView)
        NSLayoutConstraint.activate([
            coinView.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func setupPackList() {
        let titleLabel = UILabel()
        titleLabel.text = L10n.coins
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

      
        let coinIds = FirebaseManager.shared.coinProductIds
        packCardContainers = []
        let cardViews = coinIds.map { makePackCard(productId: $0) }
        let packStack = UIStackView(arrangedSubviews: cardViews)
        packStack.axis = .vertical
        packStack.spacing = 14
        packStack.alignment = .fill
        packStack.translatesAutoresizingMaskIntoConstraints = false

        let sectionStack = UIStackView(arrangedSubviews: [titleLabel, packStack])
        sectionStack.axis = .vertical
        sectionStack.spacing = 12
        sectionStack.alignment = .fill
        sectionStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(sectionStack)

        let header = contentView.subviews.first!
        NSLayoutConstraint.activate([
            sectionStack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 28),
            sectionStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sectionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            sectionStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func applyThemeToCards() {
        let accent = ThemeManager.shared.accentColor()
        let lightTint = ThemeManager.shared.lightTint()
        for container in packCardContainers {
            container.backgroundColor = lightTint
            container.layer.borderColor = accent.withAlphaComponent(0.4).cgColor
        }
    }

    private func makePackCard(productId: String) -> UIView {
    
        let coins = extractCoinAmount(from: productId)
        
        let accent = ThemeManager.shared.accentColor()
        let lightTint = ThemeManager.shared.lightTint()
        let container = UIView()
        container.backgroundColor = lightTint
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1
        container.layer.borderColor = accent.withAlphaComponent(0.4).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        packCardContainers.append(container)

        let iconView = UIImageView(image: UIImage(systemName: "circle.inset.filled"))
        iconView.tintColor = .coinYellow
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "\(coins) \(L10n.coins)"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let priceLabel = UILabel()
        priceLabel.text = "..."
        priceLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        priceLabel.textColor = .coinYellow
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        priceLabel.tag = coins

        let buyButton = UIButton(type: .system)
        buyButton.setTitle(L10n.buy, for: .normal)
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        buyButton.backgroundColor = accent
        buyButton.layer.cornerRadius = 10
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        buyButton.addAction(UIAction { [weak self] _ in
            self?.purchasePack(productId: productId, coins: coins, priceLabel: priceLabel)
        }, for: .touchUpInside)

        let typeAndPriceStack = UIStackView(arrangedSubviews: [iconView, titleLabel, priceLabel])
        typeAndPriceStack.axis = .horizontal
        typeAndPriceStack.alignment = .center
        typeAndPriceStack.spacing = 10
        typeAndPriceStack.translatesAutoresizingMaskIntoConstraints = false

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let mainStack = UIStackView(arrangedSubviews: [typeAndPriceStack, spacer, buyButton])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(mainStack)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 60),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            buyButton.widthAnchor.constraint(equalToConstant: 76),
            buyButton.heightAnchor.constraint(equalToConstant: 32),
            mainStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])

        return container
    }
    
  
    private let coinProductMapping: [String: Int] = [
      
    ]
    
    private func extractCoinAmount(from productId: String) -> Int {
        
        return coinProductMapping[productId] ?? 0
    }

    private func layoutContent() {
        let safeArea = view.safeAreaLayoutGuide
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            contentView.subviews.first!.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            contentView.subviews.first!.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentView.subviews.first!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    private func purchasePack(productId: String, coins: Int, priceLabel: UILabel) {
        Task {
            // Jailbreak kontrolü
            if SecurityUtils.isJailbroken() {
                await MainActor.run {
                    self.showErrorAlert(L10n.purchaseErrorTitle, message: "Purchase disabled on modified devices.")
                }
                return
            }
            
            guard let product = await IAPManager.shared.product(for: productId) else {
             
                await MainActor.run {
                    self.showErrorAlert(L10n.purchaseErrorTitle, message: L10n.purchaseErrorNoProduct)
                }
                return
            }
            
            do {
                let success = try await IAPManager.shared.purchase(product)
                if success {
                   
                    await MainActor.run {
                        self.showSuccess(coins: coins)
                    }
                }
              
            } catch {
               
                await MainActor.run {
                    self.showErrorAlert(L10n.purchaseErrorTitle, message: "Purchase failed. Please try again.")
                }
            }
        }
    }
    
    private func showErrorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showSuccess(coins: Int) {
        CustomAlert.present(.coinPurchaseSuccess, from: self, onPrimary: { [weak self] in
          
            self?.dismiss(animated: true) {
                self?.onDismiss?()
                MainTabBarController.shared?.selectedIndex = 2
            }
        }, onSecondary: { [weak self] in
          
            self?.dismiss(animated: true) {
                self?.onDismiss?()
               
                if let tabBar = MainTabBarController.shared,
                   let homeNav = tabBar.viewControllers?.first as? UINavigationController {
                    tabBar.selectedIndex = 0
                    let chatVC = ChatViewController()
                    homeNav.pushViewController(chatVC, animated: true)
                }
            }
        })
    }

    @objc private func closeTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.subviews.first?.frame = view.bounds
    }
}
