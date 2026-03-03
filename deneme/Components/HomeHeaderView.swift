import UIKit

final class HomeHeaderView: UIView {
    
   
    private let avatarImageView = UIImageView()
    private let avatarContainer = UIView()
    private let helloLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: .appLanguageDidChange, object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: .appLanguageDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func themeDidChange() {
        applyTheme()
        updateThemeIcon()
    }
    
    @objc private func languageDidChange() {
        updateLocalizedTexts()
    }
    
    private func updateLocalizedTexts() {
        helloLabel.text = L10n.homeHello
        titleLabel.text = L10n.homeTitle
        subtitleLabel.text = L10n.homeSubtitle
    }

    private func updateThemeIcon() {
        let assetName = ThemeManager.shared.currentTheme.assetImageName
        avatarImageView.image = UIImage(named: assetName)
    }
    
    private func applyTheme() {
        backgroundColor = ThemeManager.shared.lightTint()
        layer.borderColor = ThemeManager.shared.accentColor().withAlphaComponent(0.35).cgColor
        avatarContainer.backgroundColor = ThemeManager.shared.accentColor().withAlphaComponent(0.2)
        avatarContainer.layer.borderColor = ThemeManager.shared.accentColor().withAlphaComponent(0.4).cgColor
    }
    
 
    
    private func setupUI() {
        layer.cornerRadius = 28
        layer.borderWidth = 1
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 10)
        setupAvatar()
        setupLabels()
        applyTheme()
    }
    
    private func setupAvatar() {
        avatarContainer.layer.cornerRadius = 32
        avatarContainer.layer.borderWidth = 1
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false
        
        updateThemeIcon()
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarContainer.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarContainer.widthAnchor.constraint(equalToConstant: 64),
            avatarContainer.heightAnchor.constraint(equalToConstant: 64),
            avatarImageView.topAnchor.constraint(equalTo: avatarContainer.topAnchor, constant: 6),
            avatarImageView.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: -6),
            avatarImageView.leadingAnchor.constraint(equalTo: avatarContainer.leadingAnchor, constant: 6),
            avatarImageView.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: -6)
        ])
        
        addSubview(avatarContainer)
    }
    
    private func setupLabels() {
        helloLabel.text = L10n.homeHello
        helloLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        helloLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        
        titleLabel.text = L10n.homeTitle
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 2
        
        subtitleLabel.text = L10n.homeSubtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitleLabel.numberOfLines = 0
        
        let textStack = UIStackView(arrangedSubviews: [helloLabel, titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 6
        
        let headerStack = UIStackView(arrangedSubviews: [avatarContainer, textStack])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 16
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(headerStack)
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            headerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18)
        ])
    }
}
