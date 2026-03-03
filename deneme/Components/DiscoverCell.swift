//
//  DiscoverCell.swift
//  deneme
//

import UIKit

final class DiscoverCell: UICollectionViewCell {

    static let reuseId = "DiscoverCell"

    private let imageView = UIImageView()
    private let mistOverlay = UIView()
    private let mistGradientLayer = CAGradientLayer()
    private let priceBadge = UIView()
    private let priceIconView = UIImageView()
    private let priceLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private var onBuy: (() -> Void)?

    private let cardInset: CGFloat = 10
    private let verticalSpacing: CGFloat = 8

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
     
        mistOverlay.layer.cornerRadius = 10
        mistOverlay.clipsToBounds = true
        mistOverlay.translatesAutoresizingMaskIntoConstraints = false
        mistOverlay.isUserInteractionEnabled = false
        
      
        setupMistGradient()

        priceBadge.layer.cornerRadius = 6
        priceBadge.translatesAutoresizingMaskIntoConstraints = false

        priceIconView.image = UIImage(systemName: "circle.inset.filled")
        priceIconView.tintColor = ThemeManager.shared.accentColor()
        priceIconView.contentMode = .scaleAspectFit
        priceIconView.translatesAutoresizingMaskIntoConstraints = false

        priceLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        priceLabel.textColor = .white
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        priceBadge.addSubview(priceIconView)
        priceBadge.addSubview(priceLabel)

        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        actionButton.layer.cornerRadius = 8
        actionButton.addTarget(self, action: #selector(buyTapped), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(imageView)
        imageView.addSubview(mistOverlay)
        contentView.addSubview(priceBadge)
        contentView.addSubview(actionButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: cardInset),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: cardInset),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -cardInset),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            // Mist overlay görselin üzerinde, tam boyutta
            mistOverlay.topAnchor.constraint(equalTo: imageView.topAnchor),
            mistOverlay.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            mistOverlay.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            mistOverlay.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),

            priceBadge.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: verticalSpacing),
            priceBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: cardInset),
            priceBadge.heightAnchor.constraint(equalToConstant: 20),
            priceIconView.leadingAnchor.constraint(equalTo: priceBadge.leadingAnchor, constant: 6),
            priceIconView.centerYAnchor.constraint(equalTo: priceBadge.centerYAnchor),
            priceIconView.widthAnchor.constraint(equalToConstant: 10),
            priceIconView.heightAnchor.constraint(equalToConstant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: priceIconView.trailingAnchor, constant: 3),
            priceLabel.trailingAnchor.constraint(equalTo: priceBadge.trailingAnchor, constant: -6),
            priceLabel.centerYAnchor.constraint(equalTo: priceBadge.centerYAnchor),

            actionButton.topAnchor.constraint(equalTo: priceBadge.bottomAnchor, constant: verticalSpacing),
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: cardInset),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -cardInset),
            actionButton.heightAnchor.constraint(equalToConstant: 32),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -cardInset)
        ])
    }

    func configure(imageName: String, price: Int, isOwned: Bool, onBuy: @escaping () -> Void) {
        self.onBuy = onBuy
        contentView.backgroundColor = ThemeManager.shared.lightTint()
        contentView.layer.borderColor = ThemeManager.shared.accentColor().withAlphaComponent(0.3).cgColor
        priceBadge.backgroundColor = UIColor.coinYellow.withAlphaComponent(0.35)
        priceIconView.tintColor = .coinYellow
        imageView.image = UIImage(named: imageName)
        // titleLabel kaldırıldı - görsel isimleri gösterilmiyor
        priceLabel.text = "\(price)"
        if isOwned {
            actionButton.setTitle(L10n.purchased, for: .normal)
            actionButton.backgroundColor = UIColor.green.withAlphaComponent(0.3)
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.isEnabled = false
        } else {
            actionButton.setTitle(L10n.buy, for: .normal)
            actionButton.backgroundColor = ThemeManager.shared.accentColor().withAlphaComponent(0.9)
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.isEnabled = true
        }
        
      
        DispatchQueue.main.async { [weak self] in
            self?.updateMistGradientFrame()
        }
    }

    private func setupMistGradient() {
      
        mistGradientLayer.removeFromSuperlayer()
        
      
        mistGradientLayer.type = .radial
        mistGradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.15).cgColor,
            UIColor.white.withAlphaComponent(0.25).cgColor
        ]
        mistGradientLayer.locations = [0.0, 0.5, 1.0]
        mistGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        mistGradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        mistOverlay.layer.insertSublayer(mistGradientLayer, at: 0)
        
      
        updateMistGradientFrame()
    }
    
    private func updateMistGradientFrame() {
        guard mistGradientLayer.superlayer != nil else { return }
      
        guard mistOverlay.bounds.width > 0 && mistOverlay.bounds.height > 0 else {
            DispatchQueue.main.async { [weak self] in
                self?.updateMistGradientFrame()
            }
            return
        }
        mistGradientLayer.frame = mistOverlay.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
       
        setupMistGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
      
        updateMistGradientFrame()
    }
    
    @objc private func buyTapped() {
        onBuy?()
    }
}
