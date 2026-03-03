import UIKit

final class ThankYouViewController: UIViewController {

    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.12, green: 0.09, blue: 0.25, alpha: 1.0)
        view.layer.cornerRadius = 28
        view.layer.masksToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "checkmark.circle.fill")
        iv.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.feedbackThankYouTitle
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.feedbackThankYouMessage
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let okButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.ok, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(red: 138/255, green: 72/255, blue: 255/255, alpha: 1)
        button.layer.cornerRadius = 20
        return button
    }()
    
   
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismiss(animated: true)
        }
    }
   
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        okButton.translatesAutoresizingMaskIntoConstraints = false
        
        okButton.addTarget(self, action: #selector(okTapped), for: .touchUpInside)
        
        view.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(okButton)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            okButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            okButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            okButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            okButton.heightAnchor.constraint(equalToConstant: 50),
            okButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    @objc private func okTapped() {
        dismiss(animated: true)
    }
}
