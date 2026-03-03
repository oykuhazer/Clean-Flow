import UIKit

final class CreationGridView: UIView {
    
    weak var parentViewController: UIViewController?
    private var poemCard: ActionCardView!
    private var quatrainCard: ActionCardView!
    private var jokeCard: ActionCardView!
    private var rhymeCard: ActionCardView!
    private weak var titleLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: .appLanguageDidChange, object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: .appLanguageDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func themeDidChange() {
        applyThemeToCards()
    }
    
    @objc private func languageDidChange() {
        titleLabel?.text = L10n.whatToCreate
        poemCard?.updateTitle(L10n.creationTypePoem)
        quatrainCard?.updateTitle(L10n.creationTypeQuatrain)
        jokeCard?.updateTitle(L10n.creationTypeJoke)
        rhymeCard?.updateTitle(L10n.creationTypeRhyme)
    }
    
    private func applyThemeToCards() {
        let accent = ThemeManager.shared.accentColor()
        let light = ThemeManager.shared.lightTint()
        let secondary = ThemeManager.shared.secondaryColor()
        poemCard?.updateGradientColors([secondary, accent, light])
        quatrainCard?.updateGradientColors([accent.withAlphaComponent(0.85), light])
        jokeCard?.updateGradientColors([light, secondary, accent])
        rhymeCard?.updateGradientColors([accent, light, secondary])
    }
    
    private func setupUI() {
        let label = UILabel()
        label.text = L10n.whatToCreate
        self.titleLabel = label
        let titleLabel = label
        titleLabel.text = L10n.whatToCreate
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
   
        poemCard = ActionCardView(
            title: L10n.creationTypePoem,
            imageName: "poem",
            gradientColors: [
                UIColor(red: 0.28, green: 0.20, blue: 0.66, alpha: 1.0),
                UIColor(red: 0.58, green: 0.32, blue: 0.90, alpha: 1.0),
                UIColor(red: 0.99, green: 0.74, blue: 0.99, alpha: 1.0)
            ],
            solidColor: nil
        )
        addTapGesture(to: poemCard, type: .poem)
        
    
        quatrainCard = ActionCardView(
            title: L10n.creationTypeQuatrain,
            imageName: "quatrain",
            gradientColors: [
                UIColor(red: 0.18, green: 0.11, blue: 0.45, alpha: 1.0),
                UIColor(red: 0.32, green: 0.25, blue: 0.74, alpha: 1.0)
            ],
            solidColor: nil
        )
        addTapGesture(to: quatrainCard, type: .quatrain)
        
     
        jokeCard = ActionCardView(
            title: L10n.creationTypeJoke,
            imageName: "joke",
            gradientColors: [
                UIColor(red: 1.0, green: 0.74, blue: 0.29, alpha: 1.0),
                UIColor(red: 1.0, green: 0.55, blue: 0.33, alpha: 1.0),
                UIColor(red: 0.92, green: 0.40, blue: 0.93, alpha: 1.0)
            ],
            solidColor: nil
        )
        addTapGesture(to: jokeCard, type: .joke)
      
        rhymeCard = ActionCardView(
            title: L10n.creationTypeRhyme,
            imageName: "rhyme",
            gradientColors: [
                UIColor(red: 0.65, green: 0.45, blue: 1.0, alpha: 1.0),
                UIColor(red: 0.85, green: 0.70, blue: 1.0, alpha: 1.0),
                UIColor(red: 0.55, green: 0.35, blue: 0.95, alpha: 1.0)
            ],
            solidColor: nil
        )
        addTapGesture(to: rhymeCard, type: .rhyme)
        applyThemeToCards()
        
     
        let firstRowStack = UIStackView(arrangedSubviews: [poemCard, quatrainCard])
        firstRowStack.axis = .horizontal
        firstRowStack.alignment = .fill
        firstRowStack.distribution = .fillEqually
        firstRowStack.spacing = 14
        
        
        let secondRowStack = UIStackView(arrangedSubviews: [jokeCard, rhymeCard])
        secondRowStack.axis = .horizontal
        secondRowStack.alignment = .fill
        secondRowStack.distribution = .fillEqually
        secondRowStack.spacing = 14
        
        let actionsStack = UIStackView(arrangedSubviews: [firstRowStack, secondRowStack])
        actionsStack.axis = .vertical
        actionsStack.alignment = .fill
        actionsStack.spacing = 14
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(actionsStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            actionsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            actionsStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            actionsStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionsStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func addTapGesture(to card: ActionCardView, type: CreationType) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        card.addGestureRecognizer(tapGesture)
        card.isUserInteractionEnabled = true
      
        card.accessibilityIdentifier = type.rawValue
    }
    
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let card = gesture.view as? ActionCardView,
              let parentVC = parentViewController,
              let identifier = card.accessibilityIdentifier,
              let type = CreationType(rawValue: identifier) else { return }
        
        let chatVC = ChatViewController()
        chatVC.creationType = type
        parentVC.navigationController?.pushViewController(chatVC, animated: true)
    }
}
