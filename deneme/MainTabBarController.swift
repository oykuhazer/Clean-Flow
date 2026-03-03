import UIKit

final class MainTabBarController: UITabBarController {

    let customBar = UIView()
    private var tabStacks: [UIStackView] = []
    private var tabIcons: [UIImageView] = []
    private var tabLabels: [UILabel] = []
    
    static var shared: MainTabBarController?

    override func viewDidLoad() {
        super.viewDidLoad()
        MainTabBarController.shared = self
        setupTabs()
        configureAppearance()
        selectedIndex = 0
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCustomTabBar()
        updateCustomSelection()
    }

    @objc private func themeDidChange() {
        updateCustomSelection()
        customBar.backgroundColor = ThemeManager.shared.lightTint()
    }

    @objc private func languageDidChange() {
        let titles = [L10n.tabHome, L10n.tabFavorites, L10n.tabDiscover, L10n.tabSettings]
        viewControllers?.enumerated().forEach { index, vc in
            vc.tabBarItem?.title = titles[index]
        }
        for (index, label) in tabLabels.enumerated() where index < titles.count {
            label.text = titles[index]
        }
        navigationItem.title = nil
        (viewControllers?[selectedIndex] as? UINavigationController)?.visibleViewController?.navigationItem.title = nil
    }

    private func setupTabs() {
        let home = ViewController()
        home.title = L10n.tabHome
        let homeNav = UINavigationController(rootViewController: home)
        homeNav.tabBarItem = UITabBarItem(title: L10n.tabHome,
                                          image: UIImage(systemName: "house"),
                                          selectedImage: UIImage(systemName: "house.fill"))

        let favorites = FavoritesViewController()
        let favoritesNav = UINavigationController(rootViewController: favorites)
        favoritesNav.tabBarItem = UITabBarItem(title: L10n.tabFavorites,
                                             image: UIImage(systemName: "heart"),
                                             selectedImage: UIImage(systemName: "heart.fill"))

        let discover = DiscoverViewController()
        let discoverNav = UINavigationController(rootViewController: discover)
        discoverNav.tabBarItem = UITabBarItem(title: L10n.tabDiscover,
                                              image: UIImage(systemName: "sparkles"),
                                              selectedImage: UIImage(systemName: "sparkles"))

        let settings = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settings)
        settingsNav.tabBarItem = UITabBarItem(title: L10n.tabSettings,
                                              image: UIImage(systemName: "gearshape"),
                                              selectedImage: UIImage(systemName: "gearshape.fill"))

        viewControllers = [homeNav, favoritesNav, discoverNav, settingsNav]
    }

    private func configureAppearance() {
      
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.isHidden = true
    }


    private func setupCustomTabBar() {
        if customBar.superview != nil { return }

        customBar.backgroundColor = ThemeManager.shared.lightTint()
        customBar.layer.cornerRadius = 28
        customBar.layer.masksToBounds = false
        customBar.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        customBar.layer.shadowOpacity = 1
        customBar.layer.shadowOffset = CGSize(width: 0, height: -4)
        customBar.layer.shadowRadius = 18

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.isUserInteractionEnabled = false
        blur.layer.cornerRadius = 28
        blur.clipsToBounds = true

        let titles = [L10n.tabHome, L10n.tabFavorites, L10n.tabDiscover, L10n.tabSettings]
        let icons = ["house.fill", "heart.fill", "sparkles", "gearshape"]

        var stacks: [UIStackView] = []
        for (index, title) in titles.enumerated() {
            let iconName = icons[index]
            let (stack, iconView, label) = makeTabItem(title: title, systemImageName: iconName)
            stack.tag = index
            let tap = UITapGestureRecognizer(target: self, action: #selector(customTabTapped(_:)))
            stack.addGestureRecognizer(tap)
            stack.isUserInteractionEnabled = true
            stacks.append(stack)
            tabStacks.append(stack)
            tabIcons.append(iconView)
            tabLabels.append(label)
        }

        let stack = UIStackView(arrangedSubviews: stacks)
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 24

        view.addSubview(customBar)
        customBar.addSubview(blur)
        customBar.addSubview(stack)

        customBar.translatesAutoresizingMaskIntoConstraints = false
        blur.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            customBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            customBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            customBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            customBar.heightAnchor.constraint(equalToConstant: 70),

            blur.topAnchor.constraint(equalTo: customBar.topAnchor),
            blur.leadingAnchor.constraint(equalTo: customBar.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: customBar.trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: customBar.bottomAnchor),

            stack.topAnchor.constraint(equalTo: customBar.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: customBar.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: customBar.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: customBar.bottomAnchor, constant: -10)
        ])
    }

    private func makeTabItem(title: String, systemImageName: String) -> (UIStackView, UIImageView, UILabel) {
        let iconView = UIImageView()
        iconView.tintColor = UIColor.white.withAlphaComponent(0.8)
        iconView.contentMode = .scaleAspectFit
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconView.image = UIImage(systemName: systemImageName, withConfiguration: config)

        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4

        return (stack, iconView, label)
    }

    @objc
    private func customTabTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        selectedIndex = view.tag
        updateCustomSelection()
    }

    private func updateCustomSelection() {
        for index in 0..<tabStacks.count {
            let isSelected = index == selectedIndex
            let icon = tabIcons[index]
            let label = tabLabels[index]
            let color = isSelected ? ThemeManager.shared.accentColor() : UIColor.white.withAlphaComponent(0.8)
            icon.tintColor = color
            label.textColor = color
        }
    }

}

