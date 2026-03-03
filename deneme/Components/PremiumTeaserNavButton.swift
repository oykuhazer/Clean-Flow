
import UIKit

final class PremiumTeaserNavButton: UIView {

    var onTap: (() -> Void)?

    private let iconView = UIImageView()
    private let backgroundView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func themeDidChange() {
        let accent = ThemeManager.shared.accentColor()
        backgroundView.backgroundColor = accent.withAlphaComponent(0.2)
        backgroundView.layer.borderColor = accent.cgColor
        iconView.tintColor = accent
    }

    private func setupUI() {
        backgroundView.layer.cornerRadius = 18
        backgroundView.layer.borderWidth = 1.5
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        iconView.image = UIImage(systemName: "star.fill", withConfiguration: config)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backgroundView)
        backgroundView.addSubview(iconView)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 36),
            backgroundView.heightAnchor.constraint(equalToConstant: 36),

            iconView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18)
        ])

        themeDidChange()

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    @objc private func tapped() {
      
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
        onTap?()
    }
}
