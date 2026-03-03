
import UIKit

final class FavoritesViewController: UIViewController {

    private let tabBarBottomInset: CGFloat = 88
    
    private var favorites: [FavoriteItem] = []
    private var groupedFavorites: [CreationType: [FavoriteItem]] = [:]
    private var selectedItems: Set<UUID> = []
    private var isSelectionMode = false
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.sectionHeaderTopPadding = 0
        return tv
    }()
    
    private let emptyStateView = FavoritesEmptyStateView()
    
    private lazy var selectAllButton: UIBarButtonItem = {
        UIBarButtonItem(title: L10n.selectAll, style: .plain, target: self, action: #selector(selectAllTapped))
    }()
    
    private lazy var deleteButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteSelectedTapped))
        btn.tintColor = .systemRed
        return btn
    }()
    
    private lazy var editButton: UIBarButtonItem = {
        UIBarButtonItem(title: L10n.edit, style: .plain, target: self, action: #selector(editTapped))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.favorites
        view.backgroundColor = .clear
        view.insertSubview(BackgroundGradientView(frame: view.bounds), at: 0)
        
        setupTableView()
        setupEmptyState()
        loadFavorites()
        
        navigationItem.rightBarButtonItem = editButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoritesDidChange), name: .favoritesDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: .appLanguageDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func themeDidChange() {
        tableView.reloadData()
        emptyStateView.updateTheme()
    }
    
    @objc private func languageDidChange() {
        navigationItem.title = L10n.favorites
        editButton.title = isSelectionMode ? L10n.done : L10n.edit
        selectAllButton.title = selectedItems.count == favorites.count ? L10n.deselectAll : L10n.selectAll
        emptyStateView.updateLocalizedTexts()
        tableView.reloadData()
    }
    
    @objc private func favoritesDidChange() {
        loadFavorites()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.subviews.first?.frame = view.bounds
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reuseId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarBottomInset, right: 0)
        tableView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarBottomInset, right: 0)
        tableView.allowsMultipleSelectionDuringEditing = true
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        emptyStateView.onCreateTapped = { [weak self] in
            self?.navigateToChat()
        }
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func loadFavorites() {
        favorites = FavoriteManager.shared.fetchAll()
        groupFavorites()
        updateUI()
    }
    
    private func groupFavorites() {
        groupedFavorites = [:]
        for item in favorites {
            if let type = item.creationType {
                if groupedFavorites[type] == nil {
                    groupedFavorites[type] = []
                }
                groupedFavorites[type]?.append(item)
            }
        }
    }
    
    private func updateUI() {
        let isEmpty = favorites.isEmpty
        tableView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
        navigationItem.rightBarButtonItem = isEmpty ? nil : editButton
        
        if isEmpty && isSelectionMode {
            exitSelectionMode()
        }
        
        tableView.reloadData()
    }
    
    private func navigateToChat() {
        if let tabBar = MainTabBarController.shared,
           let homeNav = tabBar.viewControllers?.first as? UINavigationController {
            tabBar.selectedIndex = 0
            let chatVC = ChatViewController()
            homeNav.pushViewController(chatVC, animated: true)
        }
    }
    
  
    
    @objc private func editTapped() {
        if isSelectionMode {
            exitSelectionMode()
        } else {
            enterSelectionMode()
        }
    }
    
    private func enterSelectionMode() {
        isSelectionMode = true
        selectedItems.removeAll()
        tableView.setEditing(true, animated: true)
        editButton.title = L10n.done
        navigationItem.leftBarButtonItems = [selectAllButton, deleteButton]
        deleteButton.isEnabled = false
    }
    
    private func exitSelectionMode() {
        isSelectionMode = false
        selectedItems.removeAll()
        tableView.setEditing(false, animated: true)
        editButton.title = L10n.edit
        navigationItem.leftBarButtonItems = nil
    }
    
    @objc private func selectAllTapped() {
        if selectedItems.count == favorites.count {
          
            selectedItems.removeAll()
            selectAllButton.title = L10n.selectAll
        } else {
           
            selectedItems = Set(favorites.map { $0.id })
            selectAllButton.title = L10n.deselectAll
        }
        deleteButton.isEnabled = !selectedItems.isEmpty
        tableView.reloadData()
    }
    
    @objc private func deleteSelectedTapped() {
        guard !selectedItems.isEmpty else { return }
        
        let itemsToDelete = favorites.filter { selectedItems.contains($0.id) }
        FavoriteManager.shared.removeFavorites(itemsToDelete)
        exitSelectionMode()
    }
    
    private func orderedCategories() -> [CreationType] {
        let order: [CreationType] = [.poem, .quatrain, .joke, .rhyme]
        return order.filter { groupedFavorites[$0] != nil && !(groupedFavorites[$0]?.isEmpty ?? true) }
    }
}



extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        orderedCategories().count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = orderedCategories()[section]
        return groupedFavorites[category]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseId, for: indexPath) as! FavoriteCell
        let category = orderedCategories()[indexPath.section]
        if let item = groupedFavorites[category]?[indexPath.row] {
            cell.configure(with: item, isSelected: selectedItems.contains(item.id))
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let category = orderedCategories()[section]
        let header = FavoriteSectionHeader()
        header.configure(category: category)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = orderedCategories()[indexPath.section]
        guard let item = groupedFavorites[category]?[indexPath.row] else { return }
        
        if isSelectionMode {
            if selectedItems.contains(item.id) {
                selectedItems.remove(item.id)
            } else {
                selectedItems.insert(item.id)
            }
            deleteButton.isEnabled = !selectedItems.isEmpty
            selectAllButton.title = selectedItems.count == favorites.count ? L10n.deselectAll : L10n.selectAll
            tableView.reloadRows(at: [indexPath], with: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
          
            showContentDetail(item)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !isSelectionMode else { return nil }
        
        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            let category = self.orderedCategories()[indexPath.section]
            if let item = self.groupedFavorites[category]?[indexPath.row] {
                FavoriteManager.shared.removeFavorite(item)
            }
            completion(true)
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = UIColor(red: 0.9, green: 0.25, blue: 0.25, alpha: 1)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    private func showContentDetail(_ item: FavoriteItem) {
        let alert = UIAlertController(title: item.creationType?.rawValue ?? "", message: item.content, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: L10n.copy, style: .default) { _ in
            UIPasteboard.general.string = item.content
        })
        alert.addAction(UIAlertAction(title: L10n.delete, style: .destructive) { _ in
            FavoriteManager.shared.removeFavorite(item)
        })
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
        present(alert, animated: true)
    }
}

final class FavoriteCell: UITableViewCell {
    static let reuseId = "FavoriteCell"
    
    private let containerView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmarkView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isHidden = true
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(contentLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(checkmarkView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            contentLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            contentLabel.trailingAnchor.constraint(equalTo: checkmarkView.leadingAnchor, constant: -10),
            
            dateLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14),
            
            checkmarkView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmarkView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            checkmarkView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with item: FavoriteItem, isSelected: Bool) {
        contentLabel.text = item.content
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: item.createdAt)
        
        containerView.backgroundColor = ThemeManager.shared.lightTint()
        
        checkmarkView.isHidden = !isSelected
        if isSelected {
            checkmarkView.image = UIImage(systemName: "checkmark.circle.fill")
            checkmarkView.tintColor = ThemeManager.shared.accentColor()
        }
    }
}


final class FavoriteSectionHeader: UIView {
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(iconView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(category: CreationType) {
        titleLabel.text = category.rawValue
        iconView.image = UIImage(named: category.iconName)
        iconView.tintColor = ThemeManager.shared.accentColor()
    }
}


final class FavoritesEmptyStateView: UIView {
    
    var onCreateTapped: (() -> Void)?
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "heart.slash")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.noFavoritesYet
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.noFavoritesSubtitle
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.createNow, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 22
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChangeNotification), name: .themeDidChange, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func themeDidChangeNotification() {
        updateTheme()
    }
    
    func updateTheme() {
        let accent = ThemeManager.shared.accentColor()
        iconView.tintColor = accent
        createButton.backgroundColor = accent
    }
    
    func updateLocalizedTexts() {
        titleLabel.text = L10n.noFavoritesYet
        subtitleLabel.text = L10n.noFavoritesSubtitle
        createButton.setTitle(L10n.createNow, for: .normal)
    }
    
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, subtitleLabel, createButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.setCustomSpacing(24, after: subtitleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconView.widthAnchor.constraint(equalToConstant: 60),
            iconView.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.heightAnchor.constraint(equalToConstant: 44),
            createButton.widthAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    @objc private func createTapped() {
        onCreateTapped?()
    }
}
