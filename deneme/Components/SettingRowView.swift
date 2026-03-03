
import UIKit

final class SettingRowView: UIView {

    var onTap: (() -> Void)?
    private let iconView = UIImageView()
    private var subtitleLabel: UILabel?

    init(icon: String, title: String, subtitle: String? = nil) {
        super.init(frame: .zero)
        setupUI(icon: icon, title: title, subtitle: subtitle)
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI(icon: "gearshape", title: "", subtitle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func themeDidChange() {
        iconView.tintColor = ThemeManager.shared.accentColor()
    }

    private func setupUI(icon: String, title: String, subtitle: String?) {
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 12
        translatesAutoresizingMaskIntoConstraints = false

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = ThemeManager.shared.accentColor()
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label

        let arrowIcon = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowIcon.tintColor = .tertiaryLabel
        arrowIcon.contentMode = .scaleAspectFit
        arrowIcon.translatesAutoresizingMaskIntoConstraints = false

        var centerContent: [UIView] = [iconView, titleLabel]
        if let sub = subtitle, !sub.isEmpty {
            let subLabel = UILabel()
            subLabel.text = sub
            subLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            subLabel.textColor = .secondaryLabel
            subtitleLabel = subLabel
            let textStack = UIStackView(arrangedSubviews: [titleLabel, subLabel])
            textStack.axis = .vertical
            textStack.spacing = 2
            textStack.alignment = .leading
            centerContent = [iconView, textStack]
        }
        centerContent.append(arrowIcon)

        let stack = UIStackView(arrangedSubviews: centerContent)
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        isUserInteractionEnabled = true

        let rowHeight: CGFloat = subtitle != nil && !(subtitle?.isEmpty ?? true) ? 64 : 56
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: rowHeight),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            arrowIcon.widthAnchor.constraint(equalToConstant: 12),
            arrowIcon.heightAnchor.constraint(equalToConstant: 12),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    @objc private func tapped() {
        onTap?()
    }

    func updateSubtitle(_ text: String) {
        subtitleLabel?.text = text
    }
}
