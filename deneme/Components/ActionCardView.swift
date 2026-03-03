import UIKit

final class ActionCardView: UIView {
    
 
    
    private let gradientLayer = CAGradientLayer()
    private weak var titleLabel: UILabel?
    
  
    
    init(title: String, imageName: String, gradientColors: [UIColor]?, solidColor: UIColor?) {
        super.init(frame: .zero)
        setupUI(title: title, imageName: imageName, gradientColors: gradientColors, solidColor: solidColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
 
    
    private func setupUI(title: String, imageName: String, gradientColors: [UIColor]?, solidColor: UIColor?) {
        layer.cornerRadius = 32
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 0, height: 12)
        
   
        if let gradientColors = gradientColors {
            gradientLayer.colors = gradientColors.map { $0.cgColor }
            gradientLayer.locations = [0, 0.6, 1]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.cornerRadius = 32
            gradientLayer.name = "actionGradient"
            layer.insertSublayer(gradientLayer, at: 0)
        } else if let color = solidColor {
            backgroundColor = color
        }
        
      
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
     
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        self.titleLabel = label
        
     
        let vertical = UIStackView(arrangedSubviews: [imageView, label])
        vertical.axis = .vertical
        vertical.alignment = .center
        vertical.spacing = 10
        vertical.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(vertical)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: widthAnchor),
            vertical.centerXAnchor.constraint(equalTo: centerXAnchor),
            vertical.centerYAnchor.constraint(equalTo: centerYAnchor),
            vertical.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 12),
            vertical.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.45),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.6)
        ])
    }
    
    func updateGradientColors(_ colors: [UIColor]) {
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = colors.count == 2 ? [0, 1] : [0, 0.6, 1]
    }
    
    func updateTitle(_ title: String) {
        titleLabel?.text = title
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
