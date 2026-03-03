

import UIKit
import StoreKit


final class AppStoreRatingButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        setImage(UIImage(systemName: "star", withConfiguration: config), for: .normal)
        setImage(UIImage(systemName: "star", withConfiguration: config), for: .highlighted)
        tintColor = UIColor(red: 255/255, green: 213/255, blue: 79/255, alpha: 1)
        backgroundColor = .clear
        adjustsImageWhenHighlighted = false
        imageView?.layer.removeAllAnimations()

        addTarget(self, action: #selector(tapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 44),
            heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.transform = .identity
    }

    @objc private func tapped() {
        if #available(iOS 14.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        } else {
            SKStoreReviewController.requestReview()
        }
    }
}
