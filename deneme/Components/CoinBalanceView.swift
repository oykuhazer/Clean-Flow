

import UIKit


extension UIColor {
    static let coinYellow = UIColor(red: 1, green: 0.82, blue: 0.2, alpha: 1)
    static let coinYellowDark = UIColor(red: 0.95, green: 0.75, blue: 0.15, alpha: 1)
}

final class CoinBalanceView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let balanceLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let iconContainer = UIView()
    private let iconView = UIImageView()
    private var buyButton: UIButton?
    private var onBuyTapped: (() -> Void)?

    var balance: Int = 0 {
        didSet {
            updateBalance()
        }
    }

    var showBuyButton: Bool = true {
        didSet {
            buyButton?.isHidden = !showBuyButton
        }
    }

    enum Style {
        case compact
        case card     
    }

    private let style: Style

    init(style: Style = .card) {
        self.style = style
        super.init(frame: .zero)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: .appLanguageDidChange, object: nil)
    }

    required init?(coder: NSCoder) {
        self.style = .card
        super.init(coder: coder)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: .appLanguageDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func languageDidChange() {
        subtitleLabel.text = L10n.coinBalance
        buyButton?.setTitle(L10n.buy, for: .normal)
        updateBalance()
    }

    private func setupUI() {
        layer.cornerRadius = style == .compact ? 24 : 28
        layer.masksToBounds = true

        gradientLayer.name = "coinGradient"
        gradientLayer.cornerRadius = style == .compact ? 24 : 28
        gradientLayer.colors = [
            UIColor.coinYellow.withAlphaComponent(0.5).cgColor,
            UIColor.coinYellow.withAlphaComponent(0.4).cgColor,
            UIColor.coinYellowDark.withAlphaComponent(0.35).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)

        layer.borderWidth = 1
        layer.borderColor = UIColor.coinYellow.withAlphaComponent(0.6).cgColor

        iconContainer.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = style == .compact ? 18 : 22
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        iconView.image = UIImage(systemName: "circle.inset.filled")
        iconView.tintColor = .coinYellow
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)

        balanceLabel.font = UIFont.systemFont(ofSize: style == .compact ? 20 : 26, weight: .bold)
        balanceLabel.textColor = .white
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = L10n.coinBalance
        subtitleLabel.isHidden = style == .compact

        let buyBtn = UIButton(type: .system)
        buyBtn.setTitle(L10n.buy, for: .normal)
        buyBtn.setTitleColor(UIColor(red: 0.15, green: 0.08, blue: 0.22, alpha: 1), for: .normal)
        buyBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        buyBtn.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        buyBtn.layer.cornerRadius = style == .compact ? 14 : 16
        buyBtn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        buyBtn.addTarget(self, action: #selector(buyTapped), for: .touchUpInside)
        buyBtn.translatesAutoresizingMaskIntoConstraints = false
        buyButton = buyBtn

        let balanceStack = UIStackView(arrangedSubviews: [subtitleLabel, balanceLabel])
        balanceStack.axis = .vertical
        balanceStack.alignment = .leading
        balanceStack.spacing = 2
        balanceStack.translatesAutoresizingMaskIntoConstraints = false

        let mainContent: [UIView] = [iconContainer, balanceStack]
        let arranged: [UIView] = showBuyButton ? mainContent + [buyBtn] : mainContent
        let stack = UIStackView(arrangedSubviews: arranged)
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = style == .compact ? 12 : 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: style == .compact ? 40 : 48),
            iconContainer.heightAnchor.constraint(equalTo: iconContainer.widthAnchor),
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: style == .compact ? 22 : 26),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: style == .compact ? 10 : 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: style == .compact ? 14 : 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: style == .compact ? -14 : -20),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: style == .compact ? -10 : -16)
        ])
    }

    private func updateBalance() {
        let full = NSMutableAttributedString(string: "\(balance)", attributes: [
            .font: UIFont.systemFont(ofSize: style == .compact ? 20 : 26, weight: .bold),
            .foregroundColor: UIColor.white
        ])
        full.append(NSAttributedString(string: " " + L10n.coins, attributes: [
            .font: UIFont.systemFont(ofSize: style == .compact ? 14 : 16, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.9)
        ]))
        balanceLabel.attributedText = full
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func configure(balance: Int, showBuyButton: Bool = true, onBuyTapped: (() -> Void)? = nil) {
        self.balance = balance
        self.showBuyButton = showBuyButton
        self.onBuyTapped = onBuyTapped
        buyButton?.isHidden = !showBuyButton
    }

    @objc private func buyTapped() {
        onBuyTapped?()
    }
}
