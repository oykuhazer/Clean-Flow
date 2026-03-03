
import UIKit

final class ViewController: UIViewController {

    private let tabBarBottomInset: CGFloat = 88
    private var scrollView: UIScrollView!
    private var premiumTeaserButton: UIBarButtonItem?
    private var rootStack: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

  

    private func setupUI() {
        view.backgroundColor = .clear
        view.insertSubview(BackgroundGradientView(frame: view.bounds), at: 0)

        let safeArea = view.safeAreaLayoutGuide
        navigationItem.title = ""

      
        Task {
            let isPremium = await PremiumManager.shared.isPremium
            await MainActor.run {
                self.updateNavigationBarForPremiumStatus(isPremium: isPremium)
            }
        }

   
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarBottomInset, right: 0)
        scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarBottomInset, right: 0)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

    
        let headerView = HomeHeaderView()
        let coinBar = makeCoinBar()
        let creationGridView = CreationGridView()
        creationGridView.parentViewController = self

        headerView.translatesAutoresizingMaskIntoConstraints = false
        coinBar.translatesAutoresizingMaskIntoConstraints = false
        creationGridView.translatesAutoresizingMaskIntoConstraints = false

        rootStack = UIStackView(arrangedSubviews: [
            headerView,
            coinBar,
            creationGridView
        ])
        rootStack.axis = .vertical
        rootStack.alignment = .fill
        rootStack.spacing = 24
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(rootStack)

        NSLayoutConstraint.activate([
       
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rootStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }


    private var homeCoinBalanceView: CoinBalanceView?

    private func makeCoinBar() -> UIView {
        let coinView = CoinBalanceView(style: .compact)
        coinView.configure(balance: CoinManager.shared.coins, showBuyButton: true) { [weak self] in
            self?.openCoinShopFromHome()
        }
        coinView.translatesAutoresizingMaskIntoConstraints = false
        homeCoinBalanceView = coinView
        return coinView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeCoinBalanceView?.balance = CoinManager.shared.coins
        Task {
            await PremiumManager.shared.refreshStatus()
            let isPremium = await PremiumManager.shared.isPremium
            await MainActor.run {
                self.updateNavigationBarForPremiumStatus(isPremium: isPremium)
            }
        }
    }

  

    private func updateNavigationBarForPremiumStatus(isPremium: Bool) {
        if isPremium {
            navigationItem.rightBarButtonItem = nil
        } else {
            let button = PremiumTeaserNavButton()
            button.onTap = { [weak self] in self?.openPremiumScreen() }
            premiumTeaserButton = UIBarButtonItem(customView: button)
            navigationItem.rightBarButtonItem = premiumTeaserButton
        }
    }

    private func openPremiumScreen() {
        let vc = PremiumViewController()
        vc.onDismiss = { [weak self] in
            Task {
                let isPremium = await PremiumManager.shared.isPremium
                await MainActor.run {
                    self?.updateNavigationBarForPremiumStatus(isPremium: isPremium)
                }
            }
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    @objc private func openCoinShopFromHome() {
        let shop = CoinShopViewController()
        shop.onDismiss = { [weak self] in
            self?.homeCoinBalanceView?.balance = CoinManager.shared.coins
        }
        let nav = UINavigationController(rootViewController: shop)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.subviews.first?.frame = view.bounds
    }
}
