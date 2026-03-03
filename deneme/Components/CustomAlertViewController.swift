
import UIKit


struct CustomAlertButton {
    let title: String
    let isPrimary: Bool 
    let action: (() -> Void)?
}


final class CustomAlertViewController: UIViewController {

    private let image: UIImage?
    private let imageName: String?
    private let imageInCircle: Bool
    private let imageTintColor: UIColor?
    private let titleText: String
    private let messageText: String
    private let buttons: [CustomAlertButton]
    private let autoDismissAfter: TimeInterval?

    private var buttonActions: [(() -> Void)?] = []

    init(
        image: UIImage? = nil,
        imageName: String? = nil,
        imageInCircle: Bool = true,
        imageTintColor: UIColor? = nil,
        title: String,
        message: String,
        buttons: [CustomAlertButton] = [],
        autoDismissAfter: TimeInterval? = nil
    ) {
        self.image = image
        self.imageName = imageName
        self.imageInCircle = imageInCircle
        self.imageTintColor = imageTintColor
        self.titleText = title
        self.messageText = message
        self.buttons = buttons
        self.autoDismissAfter = autoDismissAfter
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        blur.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blur)
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: view.topAnchor),
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 24
        card.translatesAutoresizingMaskIntoConstraints = false

        var arranged: [UIView] = []

        if let img = image ?? (imageName.flatMap { UIImage(named: $0) }) {
            let imageContainer: UIView
            if imageInCircle {
                let circleSize: CGFloat = 100
                let circle = UIView()
                circle.backgroundColor = .white
                circle.layer.cornerRadius = circleSize / 2
                circle.clipsToBounds = true
                circle.translatesAutoresizingMaskIntoConstraints = false
                let imgView = UIImageView(image: img)
                imgView.contentMode = .scaleAspectFit
                imgView.clipsToBounds = true
                imgView.translatesAutoresizingMaskIntoConstraints = false
                if let tint = imageTintColor {
                    imgView.tintColor = tint
                    imgView.image = img.withRenderingMode(.alwaysTemplate)
                }
                circle.addSubview(imgView)
                NSLayoutConstraint.activate([
                    circle.widthAnchor.constraint(equalToConstant: circleSize),
                    circle.heightAnchor.constraint(equalToConstant: circleSize),
                    imgView.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
                    imgView.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
                    imgView.widthAnchor.constraint(equalTo: circle.widthAnchor),
                    imgView.heightAnchor.constraint(equalTo: circle.heightAnchor)
                ])
                imageContainer = circle
            } else {
                let imgView = UIImageView(image: img)
                imgView.contentMode = .scaleAspectFit
                imgView.translatesAutoresizingMaskIntoConstraints = false
                if let tint = imageTintColor {
                    imgView.tintColor = tint
                    imgView.image = img.withRenderingMode(.alwaysTemplate)
                }
                imgView.heightAnchor.constraint(equalToConstant: 80).isActive = true
                imageContainer = imgView
            }
            arranged.append(imageContainer)
        }

        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        arranged.append(titleLabel)

        let messageLabel = UILabel()
        messageLabel.text = messageText
        messageLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        arranged.append(messageLabel)

        let contentStack = UIStackView(arrangedSubviews: arranged)
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .center
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(contentStack)

        var buttonStack: UIStackView?
        if !buttons.isEmpty {
            let accent = ThemeManager.shared.accentColor()
            var buttonViews: [UIView] = []
            for (idx, btn) in buttons.enumerated() {
                let b = UIButton(type: .system)
                b.setTitle(btn.title, for: .normal)
                b.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                b.layer.cornerRadius = 14
                b.translatesAutoresizingMaskIntoConstraints = false
                b.tag = idx
                b.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                if btn.isPrimary {
                    b.setTitleColor(.white, for: .normal)
                    b.backgroundColor = accent
                } else {
                    b.setTitleColor(accent, for: .normal)
                    b.backgroundColor = .clear
                    b.layer.borderWidth = 1.5
                    b.layer.borderColor = accent.cgColor
                }
                buttonActions.append(btn.action)
                b.heightAnchor.constraint(equalToConstant: 48).isActive = true
                buttonViews.append(b)
            }
            let stack = UIStackView(arrangedSubviews: buttonViews)
            stack.axis = .vertical
            stack.spacing = 10
            stack.alignment = .fill
            stack.translatesAutoresizingMaskIntoConstraints = false
            buttonStack = stack
            card.addSubview(stack)
        }

        view.addSubview(card)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            contentStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            contentStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24)
        ])

        if let stack = buttonStack {
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: contentStack.bottomAnchor, constant: 24),
                stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
                stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
                stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28)
            ])
        } else {
            contentStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28).isActive = true
        }

        if let delay = autoDismissAfter, delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.dismiss(animated: true)
            }
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx < buttonActions.count else { return }
        dismiss(animated: true) { [weak self] in
            self?.buttonActions[idx]?()
        }
    }
}
