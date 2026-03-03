import UIKit

enum CreationType: String, CaseIterable {
    case rhyme = "Rhyme"
    case poem = "Poem"
    case quatrain = "Quatrain"
    case joke = "Joke"
    
    var iconName: String {
        switch self {
        case .rhyme: return "rhyme"
        case .poem: return "poem"
        case .quatrain: return "quatrain"
        case .joke: return "joke"
        }
    }
    
    var cost: Int {
        switch self {
        case .rhyme: return 3
        case .poem: return 8
        case .quatrain: return 6
        case .joke: return 5
        }
    }
    
    var localizedName: String {
        switch self {
        case .rhyme: return L10n.creationTypeRhyme
        case .poem: return L10n.creationTypePoem
        case .quatrain: return L10n.creationTypeQuatrain
        case .joke: return L10n.creationTypeJoke
        }
    }
}

final class ChatViewController: UIViewController {
    
   
    
    var creationType: CreationType = .rhyme {
        didSet {
           
            DispatchQueue.main.async { [weak self] in
                self?.updateUI()
            }
        }
    }
    private var credits: Int { CoinManager.shared.coins }
    

    private static let maxGenerationsPerWindow = 3
    private static let spamWindowDuration: TimeInterval = 60
    private static let spamLockDuration: TimeInterval = 60
    private static let maxConsecutiveGenerations = 100
    
   
    private static var spamLockEndTime: Date? {
        get { KeychainManager.shared.spamLockEndTime }
        set { KeychainManager.shared.spamLockEndTime = newValue }
    }
    
    private static var spamGenerationCount: Int {
        get { KeychainManager.shared.spamGenerationCount }
        set { KeychainManager.shared.spamGenerationCount = newValue }
    }
    
   
    private let creditsImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "circle.inset.filled"))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .coinYellow
        return iv
    }()
    
    private let creditsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let typeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.setTitleColor(.white, for: .selected)
        button.backgroundColor = .clear
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        button.adjustsImageWhenHighlighted = false
        button.showsTouchWhenHighlighted = false
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let chatTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.keyboardDismissMode = .interactive
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 60
        tv.contentInsetAdjustmentBehavior = .never
        tv.showsVerticalScrollIndicator = true
        tv.alwaysBounceVertical = true
        return tv
    }()
    
    private let inputContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var inputStack: UIStackView!
    
    private let inputTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = L10n.typeYourMessage
        tf.textColor = .white
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        tf.layer.cornerRadius = 20
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.rightViewMode = .always
        return tf
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 20
        return button
    }()
    
    private var messages: [ChatMessage] = []
    private weak var combinedContainerRef: UIView?

   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        updateUI()
        applyThemeColors()
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: .appLanguageDidChange, object: nil)
    }
    
    @objc private func languageDidChange() {
        updateUI()
        inputTextField.placeholder = L10n.typeYourMessage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        chatTableView.reloadData()
        scrollToBottom()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func themeDidChange() {
        applyThemeColors()
        chatTableView.reloadData()
    }

    private func applyThemeColors() {
        let accent = ThemeManager.shared.accentColor()
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        accent.getRed(&r, green: &g, blue: &b, alpha: nil)
        sendButton.backgroundColor = accent
       
        if let container = combinedContainerRef {
            container.backgroundColor = ThemeManager.shared.lightTint()
            container.layer.borderWidth = 1
            container.layer.borderColor = ThemeManager.shared.accentColor().withAlphaComponent(0.4).cgColor
        }
        typeButton.setTitleColor(ThemeManager.shared.accentColor(), for: .normal)
        typeButton.setTitleColor(ThemeManager.shared.accentColor(), for: .highlighted)
        typeButton.setTitleColor(ThemeManager.shared.accentColor(), for: .selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MainTabBarController.shared?.customBar.isHidden = true
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      
        MainTabBarController.shared?.customBar.isHidden = false
    }

    
    private func setupUI() {
        view.backgroundColor = .clear
        addBackgroundGradient()
        
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.adjustsImageWhenHighlighted = false
        backButton.showsTouchWhenHighlighted = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        
        let combinedContainer = UIView()
        combinedContainer.translatesAutoresizingMaskIntoConstraints = false
        combinedContainer.layer.cornerRadius = 18
        
      
        let creditsContainer = UIView()
        creditsContainer.translatesAutoresizingMaskIntoConstraints = false
        creditsContainer.isUserInteractionEnabled = true
        let creditsTapGesture = UITapGestureRecognizer(target: self, action: #selector(creditsTapped))
        creditsContainer.addGestureRecognizer(creditsTapGesture)
        
        creditsImageView.translatesAutoresizingMaskIntoConstraints = false
        creditsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        creditsContainer.addSubview(creditsImageView)
        creditsContainer.addSubview(creditsLabel)
        combinedContainer.addSubview(creditsContainer)
        
      
        typeButton.addTarget(self, action: #selector(typeButtonTapped), for: .touchUpInside)
        typeButton.translatesAutoresizingMaskIntoConstraints = false
        combinedContainer.addSubview(typeButton)
        
        NSLayoutConstraint.activate([
           
            creditsContainer.leadingAnchor.constraint(equalTo: combinedContainer.leadingAnchor),
            creditsContainer.topAnchor.constraint(equalTo: combinedContainer.topAnchor),
            creditsContainer.bottomAnchor.constraint(equalTo: combinedContainer.bottomAnchor),
            
            
            creditsImageView.leadingAnchor.constraint(equalTo: creditsContainer.leadingAnchor, constant: 8),
            creditsImageView.centerYAnchor.constraint(equalTo: creditsContainer.centerYAnchor),
            creditsImageView.widthAnchor.constraint(equalToConstant: 20),
            creditsImageView.heightAnchor.constraint(equalToConstant: 20),
            
            creditsLabel.leadingAnchor.constraint(equalTo: creditsImageView.trailingAnchor, constant: 4),
            creditsLabel.centerYAnchor.constraint(equalTo: creditsContainer.centerYAnchor),
            creditsLabel.trailingAnchor.constraint(equalTo: creditsContainer.trailingAnchor, constant: -4),
            
        
            typeButton.trailingAnchor.constraint(equalTo: combinedContainer.trailingAnchor, constant: -8),
            typeButton.centerYAnchor.constraint(equalTo: combinedContainer.centerYAnchor),
            typeButton.leadingAnchor.constraint(equalTo: creditsContainer.trailingAnchor, constant: 12),
            
           
            combinedContainer.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        combinedContainerRef = combinedContainer
        let combinedBarButton = UIBarButtonItem(customView: combinedContainer)
        navigationItem.rightBarButtonItem = combinedBarButton
        
     
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        chatTableView.translatesAutoresizingMaskIntoConstraints = false
        chatTableView.isHidden = false
        chatTableView.alpha = 1.0
        
    
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        inputTextField.delegate = self
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        
        inputStack = UIStackView(arrangedSubviews: [inputTextField, sendButton])
        inputStack.axis = .horizontal
        inputStack.spacing = 12
        inputStack.alignment = .center
        inputStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(chatTableView)
        view.addSubview(inputStack)
        
      
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
         
            inputStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            
            inputTextField.heightAnchor.constraint(equalToConstant: 44),
            sendButton.widthAnchor.constraint(equalToConstant: 44),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            
          
            chatTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: inputStack.topAnchor, constant: -12)
        ])
        
      
        let welcomeText = String(format: L10n.chatWelcomeMessage, creationType.rawValue.lowercased())
        let welcomeMessage = ChatMessage(text: welcomeText, isUser: false)
        messages.append(welcomeMessage)
       
    }
    
    private func addBackgroundGradient() {
        view.insertSubview(BackgroundGradientView(frame: view.bounds), at: 0)
    }
    
    private func updateUI() {
        creditsLabel.text = "\(credits)"
        let title = creationType.localizedName
        typeButton.setTitle(title, for: .normal)
        typeButton.setTitle(title, for: .highlighted)
        typeButton.setTitle(title, for: .selected)
        typeButton.setTitleColor(ThemeManager.shared.accentColor(), for: .normal)
        typeButton.setTitleColor(ThemeManager.shared.accentColor(), for: .highlighted)
        typeButton.setTitleColor(ThemeManager.shared.accentColor(), for: .selected)
        typeButton.sizeToFit()
        combinedContainerRef?.setNeedsLayout()
        combinedContainerRef?.layoutIfNeeded()
    }
    
    private func setupKeyboardObservers() {
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
       
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: 0.3) {
        
            self.inputStack.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            
            self.chatTableView.contentInset.bottom = keyboardHeight + 16
            self.chatTableView.scrollIndicatorInsets.bottom = keyboardHeight + 16
        }
        
    
        scrollToBottom()
    }
    
    @objc private func keyboardWillHide() {
        UIView.animate(withDuration: 0.3) {
        
            self.inputStack.transform = .identity
            self.chatTableView.contentInset.bottom = 0
            self.chatTableView.scrollIndicatorInsets.bottom = 0
        }
    }
    
    @objc private func handleBackgroundTap() {
        
        view.endEditing(true)
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: false)
    }
    
    @objc private func creditsTapped() {
      
        let shop = CoinShopViewController()
        shop.onDismiss = { [weak self] in
            self?.updateUI()
        }
        let nav = UINavigationController(rootViewController: shop)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }
    
    @objc private func typeButtonTapped() {
      
        let shop = CoinShopViewController()
        shop.onDismiss = { [weak self] in
            self?.updateUI()
        }
        let nav = UINavigationController(rootViewController: shop)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }
    
    @objc private func sendTapped() {
        guard let text = inputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return
        }
        
     
        if let lockEndTime = Self.spamLockEndTime, Date() < lockEndTime {
            CustomAlert.present(.spamLimitExceeded, from: self, onSingle: nil)
            return
        }
        
      
        let currentCount = Self.spamGenerationCount
        
  
        if currentCount >= Self.maxConsecutiveGenerations {
            Self.spamLockEndTime = Date().addingTimeInterval(Self.spamLockDuration * 10)
            CustomAlert.present(.spamLimitExceeded, from: self, onSingle: nil)
            return
        }
        
      
        if currentCount >= Self.maxGenerationsPerWindow {
            Self.spamLockEndTime = Date().addingTimeInterval(Self.spamLockDuration)
            Self.spamGenerationCount = 0
            CustomAlert.present(.spamLimitExceeded, from: self, onSingle: nil)
            return
        }
        
    
        Self.spamGenerationCount = currentCount + 1
        
        Task {
            let isPremium = await PremiumManager.shared.isPremium
            await MainActor.run {
                self.performSend(text: text, isPremium: isPremium)
            }
        }
    }
    
    private func performSend(text: String, isPremium: Bool) {
        
     
        let isFirstTrialGeneration = !KeychainManager.shared.hasUsedFirstTrialGeneration
        let requiredCoins: Int
        if isPremium {
            requiredCoins = 0
        } else if isFirstTrialGeneration {
            requiredCoins = 3
        } else {
            requiredCoins = creationType.cost
        }
        
      
        let userMessage = ChatMessage(text: text, isUser: true)
        messages.append(userMessage)
     
        
  
        inputTextField.text = ""
        
       
        chatTableView.reloadData()
        scrollToBottom()
        
    
        guard isPremium || CoinManager.shared.coins >= requiredCoins else {
           
            let errorMessage = ChatMessage(text: L10n.insufficientCoinsForGeneration, isUser: false)
            messages.append(errorMessage)
            chatTableView.reloadData()
            scrollToBottom()
            
         
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showInsufficientCoinsFlow()
            }
            return
        }
        
      
        let loadingMessage = ChatMessage(text: L10n.generating, isUser: false)
        messages.append(loadingMessage)
        chatTableView.reloadData()
        scrollToBottom()
        
   
        // TODO: AI content generation removed - implement your own API integration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            if let loadingIndex = self.messages.firstIndex(where: { $0.text == L10n.generating }) {
                self.messages.remove(at: loadingIndex)
            }
            
            let errorMessage = ChatMessage(text: L10n.generationError, isUser: false)
            self.messages.append(errorMessage)
            self.chatTableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    private func showInsufficientCoinsFlow() {
       
        let premiumVC = PremiumViewController()
        premiumVC.onDismiss = { [weak self] in
            guard let self = self else { return }
           
            let shop = CoinShopViewController()
            shop.onDismiss = { [weak self] in
                self?.updateUI()
            }
            let nav = UINavigationController(rootViewController: shop)
            nav.modalPresentationStyle = .pageSheet
            self.present(nav, animated: true)
        }
        present(UINavigationController(rootViewController: premiumVC), animated: true)
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self, !self.messages.isEmpty else { return }
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
           
            self.chatTableView.layoutIfNeeded()
            if indexPath.row < self.chatTableView.numberOfRows(inSection: 0) {
                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    private func showCreditsAlert() {
        CustomAlert.present(.insufficientCoins, from: self, onPrimary: { [weak self] in
            guard let self = self else { return }
            let shop = CoinShopViewController()
            shop.onDismiss = { [weak self] in self?.updateUI() }
            let nav = UINavigationController(rootViewController: shop)
            nav.modalPresentationStyle = .pageSheet
            self.present(nav, animated: true)
        }, onSecondary: { [weak self] in
            guard let self = self else { return }
            let vc = PremiumViewController()
            vc.onDismiss = { [weak self] in self?.updateUI() }
            self.present(UINavigationController(rootViewController: vc), animated: true)
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.subviews.first?.frame = view.bounds
        
  
    
        if chatTableView.frame.height == 0 {
         
        }
    }
}


extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = messages.count
      
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < messages.count else {
           
            return UITableViewCell()
        }
        let message = messages[indexPath.row]
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageCell
        cell.configure(with: message)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped()
        return true
    }
}



extension ChatViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if let touchedView = touch.view, touchedView.isDescendant(of: inputStack) {
            return false
        }
        return true
    }
}


struct ChatMessage {
    let text: String
    let isUser: Bool
    var category: CreationType?
}


final class ChatMessageCell: UITableViewCell {
    
    var onFavoriteTapped: (() -> Void)?
    private var currentMessage: ChatMessage?
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        return view
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    private var messageLabelBottomToButton: NSLayoutConstraint?
    private var messageLabelBottomToBubble: NSLayoutConstraint?
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(favoriteButton)
        
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        
        messageLabelBottomToButton = messageLabel.bottomAnchor.constraint(equalTo: favoriteButton.topAnchor, constant: -8)
        messageLabelBottomToBubble = messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 280),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
            
            favoriteButton.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            favoriteButton.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    @objc private func favoriteTapped() {
        guard let message = currentMessage, !message.isUser, let category = message.category else { return }
        let isFavorite = FavoriteManager.shared.toggleFavorite(content: message.text, category: category)
        updateFavoriteIcon(isFavorite: isFavorite)
        
       
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        onFavoriteTapped?()
    }
    
    private func updateFavoriteIcon(isFavorite: Bool) {
        let imageName = isFavorite ? "heart.fill" : "heart"
        let color = isFavorite ? ThemeManager.shared.accentColor() : UIColor.white
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteButton.tintColor = color
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leadingConstraint?.isActive = false
        trailingConstraint?.isActive = false
        messageLabelBottomToButton?.isActive = false
        messageLabelBottomToBubble?.isActive = false
        leadingConstraint = nil
        trailingConstraint = nil
        currentMessage = nil
        onFavoriteTapped = nil
    }
    
    func configure(with message: ChatMessage) {
        currentMessage = message
        messageLabel.text = message.text
        
      
        leadingConstraint?.isActive = false
        trailingConstraint?.isActive = false
        leadingConstraint = nil
        trailingConstraint = nil
        
     
        let isAIResponse = !message.isUser && message.category != nil
        let isSystemMessage = message.text == L10n.generating || message.text == L10n.insufficientCoinsForGeneration || message.text == L10n.generationError
        let showFavorite = !message.isUser && isAIResponse && !isSystemMessage
        favoriteButton.isHidden = !showFavorite
        
     
        messageLabelBottomToButton?.isActive = showFavorite
        messageLabelBottomToBubble?.isActive = !showFavorite
        
        if showFavorite {
            let isFavorite = FavoriteManager.shared.isFavorite(content: message.text)
            updateFavoriteIcon(isFavorite: isFavorite)
        }
        
        if message.isUser {
            bubbleView.backgroundColor = ThemeManager.shared.accentColor()
            trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            leadingConstraint = bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 60)
        } else {
            bubbleView.backgroundColor = ThemeManager.shared.lightTint()
            leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
            trailingConstraint = bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -60)
        }
        
        leadingConstraint?.isActive = true
        trailingConstraint?.isActive = true
        
     
        setNeedsLayout()
        layoutIfNeeded()
    }
}
