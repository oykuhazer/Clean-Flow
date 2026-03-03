import UIKit

final class TypeSelectionView: UIView {

    private let currentType: CreationType
    private let onSelect: (CreationType) -> Void
    private var typeButtons: [UIButton] = []

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    init(currentType: CreationType, onSelect: @escaping (CreationType) -> Void) {
        self.currentType = currentType
        self.onSelect = onSelect
        super.init(frame: .zero)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func themeDidChange() {
        applyTheme()
    }

    private func applyTheme() {
        let accent = ThemeManager.shared.accentColor()
        containerView.backgroundColor = ThemeManager.shared.lightTint()
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = accent.withAlphaComponent(0.4).cgColor
        for (idx, type) in CreationType.allCases.enumerated() where idx < typeButtons.count {
            let button = typeButtons[idx]
            let isSelected = type == currentType
            button.backgroundColor = isSelected ? accent : accent.withAlphaComponent(0.15)
            button.setTitleColor(isSelected ? .white : accent, for: .normal)
            button.setTitleColor(isSelected ? .white : accent, for: .highlighted)
        }
    }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let titleLabel = UILabel()
        titleLabel.text = L10n.selectType
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill

        for type in CreationType.allCases {
            let button = createTypeButton(type: type, isSelected: type == currentType)
            typeButtons.append(button)
            stack.addArrangedSubview(button)
        }

        containerView.addSubview(titleLabel)
        containerView.addSubview(stack)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: 220),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        applyTheme()
    }

    private func createTypeButton(type: CreationType, isSelected: Bool) -> UIButton {
        let accent = ThemeManager.shared.accentColor()
        let button = UIButton(type: .custom)
        button.setTitle(type.rawValue, for: .normal)
        button.setTitle(type.rawValue, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = isSelected ? accent : accent.withAlphaComponent(0.15)
        button.setTitleColor(isSelected ? .white : accent, for: .normal)
        button.setTitleColor(isSelected ? .white : accent, for: .highlighted)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.adjustsImageWhenHighlighted = false
        button.showsTouchWhenHighlighted = false
        button.addTarget(self, action: #selector(typeSelected(_:)), for: .touchUpInside)
        button.tag = type.hashValue
        return button
    }
    
    @objc private func typeSelected(_ sender: UIButton) {
        guard let type = CreationType.allCases.first(where: { $0.hashValue == sender.tag }) else { return }
        onSelect(type)
        dismiss()
    }
    
    func present(from viewController: UIViewController, sourceView: UIView) {
        guard let window = viewController.view.window else { return }
        
        frame = window.bounds
        window.addSubview(self)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.topAnchor.constraint(equalTo: sourceView.bottomAnchor, constant: 8)
        ])
        
      
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismiss() {
        removeFromSuperview()
    }
}
