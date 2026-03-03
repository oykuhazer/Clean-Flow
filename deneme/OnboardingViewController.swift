
import UIKit

final class OnboardingViewController: UIViewController {
    
    var onComplete: (() -> Void)?
    
    private var currentPage = 0
    private let totalPages = 5
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.bounces = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private let nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let skipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Skip", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private var pageViews: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPages()
        updateUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: .appLanguageDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func languageDidChange() {
        refreshAllTexts()
    }
    
    private func refreshAllTexts() {
      
        skipButton.setTitle("Skip", for: .normal)
        let isLastPage = currentPage == totalPages - 1
        nextButton.setTitle(isLastPage ? L10n.getStarted : L10n.nextButton, for: .normal)
        
      
        for pageView in pageViews {
            pageView.removeFromSuperview()
        }
        pageViews.removeAll()
        setupPages()
        
    
        let pageWidth = scrollView.bounds.width
        scrollView.setContentOffset(CGPoint(x: CGFloat(currentPage) * pageWidth, y: 0), animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.subviews.first?.frame = view.bounds
        
        let pageWidth = scrollView.bounds.width
        for (index, pageView) in pageViews.enumerated() {
            pageView.frame = CGRect(x: CGFloat(index) * pageWidth, y: 0, width: pageWidth, height: scrollView.bounds.height)
        }
        scrollView.contentSize = CGSize(width: pageWidth * CGFloat(totalPages), height: scrollView.bounds.height)
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        view.insertSubview(BackgroundGradientView(frame: view.bounds, useFixedTheme: .default), at: 0)
        
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        view.addSubview(skipButton)
        
        scrollView.delegate = self
        
        pageControl.numberOfPages = totalPages
        pageControl.currentPageIndicatorTintColor = AppThemeId.default.accentColor
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        
        nextButton.backgroundColor = AppThemeId.default.accentColor
        nextButton.setTitle(L10n.nextButton, for: .normal)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 56),
            
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupPages() {
        
        let page1 = createWelcomePage()
        pageViews.append(page1)
        scrollView.addSubview(page1)
        
      
        let page2 = createAICreationPage()
        pageViews.append(page2)
        scrollView.addSubview(page2)
        
     
        let page3 = createFavoritesPage()
        pageViews.append(page3)
        scrollView.addSubview(page3)
        
    
        let page4 = createSharePage()
        pageViews.append(page4)
        scrollView.addSubview(page4)
        
       
        let page5 = createThemesPage()
        pageViews.append(page5)
        scrollView.addSubview(page5)
    }
    
 
    
    private func createWelcomePage() -> UIView {
        let container = UIView()
     
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
    
        let iconView = UIImageView(image: UIImage(named: "AppIcon"))
        iconView.contentMode = .scaleAspectFit
        iconView.layer.cornerRadius = 32
        iconView.clipsToBounds = true
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
      
        let appNameLabel = UILabel()
        appNameLabel.text = L10n.appName
        appNameLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        appNameLabel.textColor = .white
        appNameLabel.textAlignment = .center
        
   
        let descLabel = UILabel()
        descLabel.text = L10n.onboardingAppDescription
        descLabel.font = UIFont.systemFont(ofSize: 17)
        descLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.lineBreakMode = .byWordWrapping
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentStack.addArrangedSubview(iconView)
        contentStack.addArrangedSubview(appNameLabel)
        contentStack.addArrangedSubview(descLabel)
        
        contentStack.setCustomSpacing(28, after: iconView)
        contentStack.setCustomSpacing(16, after: appNameLabel)
        
        container.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -40),
            contentStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 40),
            contentStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -40),
            
            descLabel.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor)
        ])
        
        return container
    }
    
   
    
    private func createAICreationPage() -> UIView {
        let container = UIView()
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
       
        let titleLabel = UILabel()
        titleLabel.text = L10n.onboardingAITitle
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
     
        let subtitleLabel = UILabel()
        subtitleLabel.text = L10n.onboardingAISubtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let gridView = create2x2Grid()
        gridView.translatesAutoresizingMaskIntoConstraints = false
        
     
        let chatSimulation = createChatSimulationView()
        chatSimulation.translatesAutoresizingMaskIntoConstraints = false
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(gridView)
        contentStack.addArrangedSubview(chatSimulation)
        
        contentStack.setCustomSpacing(16, after: titleLabel)
        contentStack.setCustomSpacing(32, after: subtitleLabel)
        contentStack.setCustomSpacing(28, after: gridView)
        
        container.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            
            gridView.widthAnchor.constraint(equalToConstant: 280),
            gridView.heightAnchor.constraint(equalToConstant: 140),
            
            chatSimulation.widthAnchor.constraint(equalTo: contentStack.widthAnchor),
            chatSimulation.heightAnchor.constraint(equalToConstant: 160)
        ])
        
        return container
    }
    
    private func create2x2Grid() -> UIView {
        let container = UIView()
        
        let types: [(name: String, image: String)] = [
            ("Poem", "poem"),
            ("Quatrain", "quatrain"),
            ("Joke", "joke"),
            ("Rhyme", "rhyme")
        ]
        
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.distribution = .fillEqually
        row1.spacing = 12
        
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.distribution = .fillEqually
        row2.spacing = 12
        
        for (index, type) in types.enumerated() {
            let card = createMiniCard(title: type.name, imageName: type.image)
            if index < 2 {
                row1.addArrangedSubview(card)
            } else {
                row2.addArrangedSubview(card)
            }
        }
        
        let mainStack = UIStackView(arrangedSubviews: [row1, row2])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: container.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func createMiniCard(title: String, imageName: String) -> UIView {
        let card = UIView()
        card.backgroundColor = AppThemeId.default.lightTint
        card.layer.cornerRadius = 16
        
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(imageView)
        card.addSubview(label)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 64),
            
            imageView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            imageView.widthAnchor.constraint(equalToConstant: 28),
            imageView.heightAnchor.constraint(equalToConstant: 28),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            label.centerXAnchor.constraint(equalTo: card.centerXAnchor)
        ])
        
        return card
    }
    
    private func createChatSimulationView() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        container.layer.cornerRadius = 20
        
        let userBubble = createMessageBubble(text: "Write me a poem ✨", isUser: true)
        let aiBubble = createMessageBubble(text: "Stars above so bright,\nGuiding dreams through night.", isUser: false)
        
        container.addSubview(userBubble)
        container.addSubview(aiBubble)
        
        userBubble.translatesAutoresizingMaskIntoConstraints = false
        aiBubble.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userBubble.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            userBubble.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            userBubble.widthAnchor.constraint(lessThanOrEqualToConstant: 180),
            
            aiBubble.topAnchor.constraint(equalTo: userBubble.bottomAnchor, constant: 12),
            aiBubble.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            aiBubble.widthAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])
        
        return container
    }
    
    private func createMessageBubble(text: String, isUser: Bool) -> UIView {
        let bubble = UIView()
        bubble.backgroundColor = isUser ? AppThemeId.default.accentColor : AppThemeId.default.lightTint
        bubble.layer.cornerRadius = 16
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        bubble.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -14),
            label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -10)
        ])
        
        return bubble
    }
    
    
    private func createFavoritesPage() -> UIView {
        let container = UIView()
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = L10n.onboardingFavoritesTitle
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = L10n.onboardingFavoritesSubtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let favSimulation = createFavoritesSimulation()
        favSimulation.translatesAutoresizingMaskIntoConstraints = false
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(favSimulation)
        
        contentStack.setCustomSpacing(12, after: titleLabel)
        contentStack.setCustomSpacing(30, after: subtitleLabel)
        
        container.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            
            favSimulation.widthAnchor.constraint(equalToConstant: 300),
            favSimulation.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        return container
    }
    
    private func createFavoritesSimulation() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        container.layer.cornerRadius = 20
        
        let items = [
            ("A poem about the moon...", true),
            ("Funny joke about cats...", true),
            ("Rhyme for birthday...", false)
        ]
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        for item in items {
            let row = createFavoriteItemRow(text: item.0, isFavorited: item.1)
            stack.addArrangedSubview(row)
        }
        
        container.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createFavoriteItemRow(text: String, isFavorited: Bool) -> UIView {
        let row = UIView()
        row.backgroundColor = AppThemeId.default.lightTint
        row.layer.cornerRadius = 14
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let heartView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        heartView.image = UIImage(systemName: isFavorited ? "heart.fill" : "heart", withConfiguration: config)
        heartView.tintColor = isFavorited ? AppThemeId.default.accentColor : UIColor.white.withAlphaComponent(0.5)
        heartView.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(label)
        row.addSubview(heartView)
        
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 52),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            heartView.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            heartView.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        
        return row
    }
    
  
    
    private func createSharePage() -> UIView {
        let container = UIView()
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = L10n.onboardingShareTitle
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = L10n.onboardingShareSubtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let shareSimulation = createShareSimulation()
        shareSimulation.translatesAutoresizingMaskIntoConstraints = false
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(shareSimulation)
        
        contentStack.setCustomSpacing(12, after: titleLabel)
        contentStack.setCustomSpacing(40, after: subtitleLabel)
        
        container.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            
            shareSimulation.widthAnchor.constraint(equalToConstant: 280),
            shareSimulation.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        return container
    }
    
    private func createShareSimulation() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        container.layer.cornerRadius = 20
        
        let contentCard = UIView()
        contentCard.backgroundColor = AppThemeId.default.lightTint
        contentCard.layer.cornerRadius = 16
        contentCard.translatesAutoresizingMaskIntoConstraints = false
        
        let poemLabel = UILabel()
        poemLabel.text = "\"Stars above so bright...\""
        poemLabel.font = UIFont.italicSystemFont(ofSize: 15)
        poemLabel.textColor = .white
        poemLabel.textAlignment = .center
        poemLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentCard.addSubview(poemLabel)
        
        let shareStack = UIStackView()
        shareStack.axis = .horizontal
        shareStack.spacing = 24
        shareStack.alignment = .center
        shareStack.translatesAutoresizingMaskIntoConstraints = false
        
        let shareIcons = ["message.fill", "square.and.arrow.up", "doc.on.doc"]
        for iconName in shareIcons {
            let iconContainer = UIView()
            iconContainer.backgroundColor = AppThemeId.default.accentColor.withAlphaComponent(0.3)
            iconContainer.layer.cornerRadius = 25
            iconContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let iconView = UIImageView()
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            iconView.image = UIImage(systemName: iconName, withConfiguration: config)
            iconView.tintColor = .white
            iconView.translatesAutoresizingMaskIntoConstraints = false
            
            iconContainer.addSubview(iconView)
            
            NSLayoutConstraint.activate([
                iconContainer.widthAnchor.constraint(equalToConstant: 50),
                iconContainer.heightAnchor.constraint(equalToConstant: 50),
                iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
                iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor)
            ])
            
            shareStack.addArrangedSubview(iconContainer)
        }
        
        container.addSubview(contentCard)
        container.addSubview(shareStack)
        
        NSLayoutConstraint.activate([
            poemLabel.centerXAnchor.constraint(equalTo: contentCard.centerXAnchor),
            poemLabel.centerYAnchor.constraint(equalTo: contentCard.centerYAnchor),
            
            contentCard.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            contentCard.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            contentCard.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            contentCard.heightAnchor.constraint(equalToConstant: 70),
            
            shareStack.topAnchor.constraint(equalTo: contentCard.bottomAnchor, constant: 24),
            shareStack.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        return container
    }
    

    
    private func createThemesPage() -> UIView {
        let container = UIView()
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = L10n.onboardingThemesTitle
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = L10n.onboardingThemesSubtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
       
        let themeShowcase = createThemeShowcase()
        themeShowcase.translatesAutoresizingMaskIntoConstraints = false
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(themeShowcase)
        
        contentStack.setCustomSpacing(12, after: titleLabel)
        contentStack.setCustomSpacing(30, after: subtitleLabel)
        
        container.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            
            themeShowcase.widthAnchor.constraint(equalToConstant: 300),
            themeShowcase.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        return container
    }
    
    private func createThemeShowcase() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        container.layer.cornerRadius = 20
        
       
        let themeImages = ["default", "1", "2", "3", "4", "5", "6", "7", "8"]
        
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.distribution = .fillEqually
        row1.spacing = 8
        
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.distribution = .fillEqually
        row2.spacing = 8
        
        let row3 = UIStackView()
        row3.axis = .horizontal
        row3.distribution = .fillEqually
        row3.spacing = 8
        
        for (index, imageName) in themeImages.enumerated() {
            let themeCard = createThemeCard(imageName: imageName)
            if index < 3 {
                row1.addArrangedSubview(themeCard)
            } else if index < 6 {
                row2.addArrangedSubview(themeCard)
            } else {
                row3.addArrangedSubview(themeCard)
            }
        }
        
        let mainStack = UIStackView(arrangedSubviews: [row1, row2, row3])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createThemeCard(imageName: String) -> UIView {
        let card = UIView()
        card.backgroundColor = AppThemeId.default.lightTint
        card.layer.cornerRadius = 16
        card.clipsToBounds = true
        
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 80),
            imageView.topAnchor.constraint(equalTo: card.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        
        return card
    }
    
 
    
    private func updateUI() {
        pageControl.currentPage = currentPage
        
        let isLastPage = currentPage == totalPages - 1
        nextButton.setTitle(isLastPage ? L10n.getStarted : L10n.nextButton, for: .normal)
        skipButton.isHidden = isLastPage
    }
    
    @objc private func nextTapped() {
        if currentPage < totalPages - 1 {
            currentPage += 1
            let offset = CGFloat(currentPage) * scrollView.bounds.width
            scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
            updateUI()
        } else {
            finishOnboarding()
        }
    }
    
    @objc private func skipTapped() {
        finishOnboarding()
    }
    
    private func finishOnboarding() {
        onComplete?()
    }
}



extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        if page != currentPage && page >= 0 && page < totalPages {
            currentPage = page
            updateUI()
        }
    }
}
