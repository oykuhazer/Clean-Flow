import UIKit

final class SpecialOfferView: UIView {
    
  
    
    private let gradientLayer = CAGradientLayer()
    
  
    
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
        gradientLayer.colors = [
            UIColor(red: 255/255, green: 213/255, blue: 79/255, alpha: 1).cgColor,
            UIColor(red: 255/255, green: 163/255, blue: 72/255, alpha: 1).cgColor,
            accent.cgColor
        ]
    }
    
    private func setupUI() {
        backgroundColor = .clear
        layer.cornerRadius = 26
        layer.masksToBounds = true
        layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 10)
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 26
        gradientLayer.name = "specialOfferGradient"
        layer.insertSublayer(gradientLayer, at: 0)
        themeDidChange()
        
  
        let imageView = UIImageView(image: UIImage(named: "special_offer"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
    
        let titleLabel = UILabel()
        titleLabel.text = L10n.specialOfferTitle
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor.black
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = L10n.specialOfferSubtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = UIColor.black.withAlphaComponent(0.9)
        subtitleLabel.numberOfLines = 0
        
   
        let ctaButton = UIButton(type: .system)
        ctaButton.setTitle(L10n.premiumContinue, for: .normal)
        ctaButton.setTitleColor(ThemeManager.shared.accentColor(), for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        ctaButton.backgroundColor = UIColor.white
        ctaButton.layer.cornerRadius = 18
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        
   
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, ctaButton])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 8
        
        let mainStack = UIStackView(arrangedSubviews: [textStack, imageView])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -18),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
