import UIKit

final class FeedbackViewController: UIViewController {

    private let onDismiss: () -> Void
    private let starRatingView = StarRatingView()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.14, green: 0.11, blue: 0.28, alpha: 1.0)
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
        label.text = L10n.feedbackTitle
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
        label.text = L10n.feedbackPlaceholder
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
        button.backgroundColor = UIColor(red: 138/255, green: 72/255, blue: 255/255, alpha: 1)
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

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.feedbackRating
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.textAlignment = .center
        return label
    }()

    init(onDismiss: @escaping () -> Void) {
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
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        starRatingView.translatesAutoresizingMaskIntoConstraints = false
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
        contentStack.addArrangedSubview(ratingLabel)
        contentStack.addArrangedSubview(starRatingView)
        contentStack.addArrangedSubview(sendButton)
        contentStack.addArrangedSubview(cancelButton)

        textView.heightAnchor.constraint(equalToConstant: 96).isActive = true
        starRatingView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let containerHeight = containerView.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor)
        containerHeight.priority = .defaultHigh

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            containerView.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.72),
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
        let feedback = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !feedback.isEmpty else { return }
        dismiss(animated: true) { self.onDismiss() }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

extension FeedbackViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
