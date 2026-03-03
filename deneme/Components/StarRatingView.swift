

import UIKit


final class StarRatingView: UIView {

    var rating: Int = 0 {
        didSet { updateStars() }
    }
    var onRatingChange: ((Int) -> Void)?

    private var starButtons: [UIButton] = []
    private let starCount = 5
    private let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        for i in 1...starCount {
            let btn = UIButton(type: .custom)
            btn.tag = i
            let starOutline = UIImage(systemName: "star", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
            let starFilled = UIImage(systemName: "star.fill", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
            btn.setImage(starOutline, for: .normal)
            btn.setImage(starFilled, for: .selected)
            btn.setImage(starFilled, for: .highlighted)
            btn.tintColor = unselectedColor
            btn.backgroundColor = .clear
            btn.adjustsImageWhenHighlighted = false
            btn.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starButtons.append(btn)
            stack.addArrangedSubview(btn)
        }

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private var selectedColor: UIColor {
        UIColor(red: 255/255, green: 213/255, blue: 79/255, alpha: 1)
    }

    private var unselectedColor: UIColor {
        UIColor.white.withAlphaComponent(0.35)
    }

    private func updateStars() {
        for (index, btn) in starButtons.enumerated() {
            let filled = (index + 1) <= rating
            btn.isSelected = filled
            btn.tintColor = filled ? selectedColor : unselectedColor
        }
    }

    @objc private func starTapped(_ sender: UIButton) {
        rating = sender.tag
        onRatingChange?(rating)
    }
}
