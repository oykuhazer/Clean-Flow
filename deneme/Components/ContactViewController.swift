import UIKit
import MessageUI

final class ContactViewController: UIViewController {

    private let onDismiss: () -> Void
    private weak var presenterVC: UIViewController?

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.contactUs
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        tv.textColor = .white
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.layer.cornerRadius = 12
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return tv
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.typeYourMessage
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.white.withAlphaComponent(0.45)
        label.numberOfLines = 0
        return label
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.sendFeedback, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 14
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.cancel, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.65), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return button
    }()

    init(presenter: UIViewController? = nil, onDismiss: @escaping () -> Void) {
        self.presenterVC = presenter
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
        applyTheme()
    }
    
    private func applyTheme() {
        let accentColor = ThemeManager.shared.accentColor()
       
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        accentColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        containerView.backgroundColor = UIColor(red: r * 0.15, green: g * 0.15, blue: b * 0.15, alpha: 1.0)
        sendButton.backgroundColor = accentColor
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
    
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        textView.delegate = self
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        view.addSubview(containerView)
        containerView.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(titleLabel)
        let textContainer = UIView()
        textContainer.addSubview(textView)
        textContainer.addSubview(placeholderLabel)
        contentStack.addArrangedSubview(textContainer)
        contentStack.addArrangedSubview(sendButton)
        contentStack.addArrangedSubview(cancelButton)

        textView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let containerHeight = containerView.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor)
        containerHeight.priority = .defaultHigh

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            containerView.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.6),
            containerHeight,

            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: textContainer.topAnchor),
            textView.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -16)
        ])
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = keyboardFrame.height - view.safeAreaInsets.bottom
    }

    @objc private func keyboardWillHide() {
        scrollView.contentInset.bottom = 0
    }

    @objc private func sendTapped() {
        let message = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
     
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
        let deviceModel = getDeviceModel()
        
       
        let mailBody = """
        Mesaj:
        \(message)
        
    
        """
   
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setToRecipients(["0@gmail.com"])
            mailVC.setSubject("Uygulama Geri Bildirimi")
            mailVC.setMessageBody(mailBody, isHTML: false)
            present(mailVC, animated: true)
        } else {
            
            dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.showSuccessAlert()
            }
        }
    }
    
    private func showSuccessAlert() {
        if let presenter = presenterVC {
            CustomAlert.present(.contactSuccess, from: presenter, onSingle: nil)
        } else if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .windows.first(where: { $0.isKeyWindow })?
            .rootViewController {
            var presenter = topVC
            while let presented = presenter.presentedViewController {
                presenter = presented
            }
            CustomAlert.present(.contactSuccess, from: presenter, onSingle: nil)
        }
    }
    
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
       
        let modelMap: [String: String] = [
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,5": "iPhone 13",
            "iPhone14,6": "iPhone SE (3rd gen)",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone17,1": "iPhone 16 Pro",
            "iPhone17,2": "iPhone 16 Pro Max",
            "iPhone17,3": "iPhone 16",
            "iPhone17,4": "iPhone 16 Plus"
        ]
        
        return modelMap[identifier] ?? identifier
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ContactViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

extension ContactViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
           
            self.dismiss(animated: true) {
                if result == .sent {
                   
                    self.showSuccessAlert()
                }
                self.onDismiss()
            }
        }
    }
}
