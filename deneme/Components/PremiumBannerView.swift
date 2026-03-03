

import UIKit

final class PremiumBannerView: UIView {

    var onTap: (() -> Void)?
    private let iconView = UIImageView(image: UIImage(systemName: "crown.fill"))
    private weak var titleLabel: UILabel?
    private weak var subtitleLabel: UILabel?

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
        backgroundColor = ThemeManager.shared.lightTint()
        layer.borderColor = ThemeManager.shared.accentColor().withAlphaComponent(0.5).cgColor
        iconView.tintColor = ThemeManager.shared.accentColor()
    }
    
    @objc private func languageDidChange() {
        titleLabel?.text = L10n.myPremiumService
        subtitleLabel?.text = L10n.premiumBullet2Sub
    }

    private func setupUI() {
        layer.cornerRadius = 20
        layer.borderWidth = 1
        translatesAutoresizingMaskIntoConstraints = false

        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = L10n.myPremiumService
        title.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        title.textColor = .white
        self.titleLabel = title

        let subtitle = UILabel()
        subtitle.text = L10n.premiumBullet2Sub
        subtitle.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitle.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitle.numberOfLines = 0
        self.subtitleLabel = subtitle

        let textStack = UIStackView(arrangedSubviews: [title, subtitle])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 4

        let arrowIcon = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowIcon.tintColor = .white
        arrowIcon.contentMode = .scaleAspectFit
        arrowIcon.translatesAutoresizingMaskIntoConstraints = false

        let mainStack = UIStackView(arrangedSubviews: [iconView, textStack, arrowIcon])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainStack)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        isUserInteractionEnabled = true

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 70),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            arrowIcon.widthAnchor.constraint(equalToConstant: 16),
            arrowIcon.heightAnchor.constraint(equalToConstant: 16),
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        themeDidChange()
    }

    @objc private func tapped() {
        onTap?()
    }
}
