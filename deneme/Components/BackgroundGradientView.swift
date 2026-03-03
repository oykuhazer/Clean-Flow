//
//  BackgroundGradientView.swift
//  deneme
//

import UIKit

final class BackgroundGradientView: UIView {

    private let gradientLayer = CAGradientLayer()
    private var fixedTheme: AppThemeId?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
    }
    
    convenience init(frame: CGRect, useFixedTheme: AppThemeId) {
        self.init(frame: frame)
        self.fixedTheme = useFixedTheme
        applyThemeGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupGradient() {
        gradientLayer.name = "backgroundGradient"
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
        applyThemeGradient()
    }

    @objc private func themeDidChange() {
        if fixedTheme == nil {
            applyThemeGradient()
        }
    }

    private func applyThemeGradient() {
        let accent = fixedTheme?.accentColor ?? ThemeManager.shared.accentColor()
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        accent.getRed(&r, green: &g, blue: &b, alpha: nil)
        let dark1 = UIColor(red: r * 0.12, green: g * 0.12, blue: b * 0.2, alpha: 1)
        let dark2 = UIColor(red: r * 0.18, green: g * 0.18, blue: b * 0.28, alpha: 1)
        let dark3 = UIColor(red: r * 0.28, green: g * 0.28, blue: b * 0.4, alpha: 1)
        gradientLayer.colors = [dark1.cgColor, dark2.cgColor, dark3.cgColor]
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 0
    }
}
