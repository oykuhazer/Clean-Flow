

import UIKit

final class DiscoverViewController: UIViewController {

    private var coinBalanceView: CoinBalanceView!
    private var collectionView: UICollectionView!
    private let manager = CoinManager.shared
    private let tabBarBottomInset: CGFloat = 88
    private var premiumTeaserButton: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = ""
        view.backgroundColor = .clear
        view.insertSubview(BackgroundGradientView(frame: view.bounds), at: 0)
        Task {
            let isPremium = await PremiumManager.shared.isPremium
            await MainActor.run {
                self.updateNavigationBarForPremiumStatus(isPremium: isPremium)
            }
        }
        setupCoinHeader()
        setupCollectionView()
        layoutContent()
        manager.onCoinsDidChange = { [weak self] in self?.refreshCoinLabel() }
        refreshCoinLabel()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarBottomInset, right: 0)
        collectionView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarBottomInset, right: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func themeDidChange() {
        collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        refreshCoinLabel()
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.subviews.first?.frame = view.bounds
    }

    private func setupCoinHeader() {
        let balanceView = CoinBalanceView(style: .card)
        balanceView.configure(balance: manager.coins, showBuyButton: true) { [weak self] in
            self?.openCoinShop()
        }
        balanceView.translatesAutoresizingMaskIntoConstraints = false
        coinBalanceView = balanceView
        view.addSubview(balanceView)
        NSLayoutConstraint.activate([balanceView.heightAnchor.constraint(equalToConstant: 88)])
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DiscoverCell.self, forCellWithReuseIdentifier: DiscoverCell.reuseId)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
    }

    private func layoutContent() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            coinBalanceView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            coinBalanceView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            coinBalanceView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            collectionView.topAnchor.constraint(equalTo: coinBalanceView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    private func refreshCoinLabel() {
        coinBalanceView?.balance = manager.coins
    }

    private func openCoinShop() {
        let shop = CoinShopViewController()
        shop.onDismiss = { [weak self] in
            self?.refreshCoinLabel()
            self?.collectionView.reloadData()
        }
        let nav = UINavigationController(rootViewController: shop)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }
}



extension DiscoverViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        CoinManager.discoverImageIds.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiscoverCell.reuseId, for: indexPath) as! DiscoverCell
        let id = CoinManager.discoverImageIds[indexPath.item]
        let price = manager.price(forDiscoverImageId: id)
        let owned = manager.isOwned(discoverImageId: id)
        cell.configure(imageName: id, price: price, isOwned: owned) { [weak self] in
            self?.purchaseItem(id: id, at: indexPath)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.bounds.width
        let spacing: CGFloat = 12
        let twoColumns = (totalWidth - spacing) / 2
        let cardInset: CGFloat = 10
        let verticalSpacing: CGFloat = 8
       
        let bottomHeight: CGFloat = cardInset + verticalSpacing + 20 + verticalSpacing + 32 + cardInset
        return CGSize(width: twoColumns, height: twoColumns + bottomHeight)
    }

    private func purchaseItem(id: String, at indexPath: IndexPath) {
        guard manager.purchaseDiscoverImage(id: id) else {
            CustomAlert.present(.insufficientCoins, from: self, onPrimary: { [weak self] in
                self?.openCoinShop()
            }, onSecondary: { [weak self] in
                guard let self = self else { return }
                let vc = PremiumViewController()
                vc.onDismiss = { [weak self] in self?.refreshCoinLabel() }
                self.present(UINavigationController(rootViewController: vc), animated: true)
            })
            return
        }
        collectionView.reloadItems(at: [indexPath])
        refreshCoinLabel()
    }
}
