
import UIKit

final class PurchaseSuccessAlertViewController: UIViewController {

    var onSeeThemes: (() -> Void)?
    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve

        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 24
        card.translatesAutoresizingMaskIntoConstraints = false

      
        let circleSize: CGFloat = 100
        let circle = UIView()
        circle.backgroundColor = .white
        circle.layer.cornerRadius = circleSize / 2
        circle.clipsToBounds = true
        circle.translatesAutoresizingMaskIntoConstraints = false

        let imgView = UIImageView(image: UIImage(named: "inapppurchase"))
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(imgView)

        let titleLabel = UILabel()
        titleLabel.text = L10n.purchaseSuccessTitle
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        let seeThemesButton = UIButton(type: .system)
        seeThemesButton.setTitle(L10n.seeThemes, for: .normal)
        seeThemesButton.setTitleColor(.white, for: .normal)
        seeThemesButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        seeThemesButton.backgroundColor = ThemeManager.shared.accentColor()
        seeThemesButton.layer.cornerRadius = 14
        seeThemesButton.translatesAutoresizingMaskIntoConstraints = false
        seeThemesButton.addTarget(self, action: #selector(seeThemesTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [circle, titleLabel, seeThemesButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(card)
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28),

            circle.widthAnchor.constraint(equalToConstant: circleSize),
            circle.heightAnchor.constraint(equalToConstant: circleSize),
            imgView.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            imgView.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            imgView.widthAnchor.constraint(equalTo: circle.widthAnchor),
            imgView.heightAnchor.constraint(equalTo: circle.heightAnchor),

            seeThemesButton.heightAnchor.constraint(equalToConstant: 48),
            seeThemesButton.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped)))
    }

    @objc private func seeThemesTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onSeeThemes?()
        }
    }

    @objc private func backgroundTapped(_ recognizer: UITapGestureRecognizer) {
        if recognizer.location(in: view).y < view.bounds.midY || recognizer.location(in: view).y > view.bounds.midY + 200 {
            dismiss(animated: true) { [weak self] in self?.onDismiss?() }
        }
    }
}
