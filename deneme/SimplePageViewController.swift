import UIKit

final class SimplePageViewController: UIViewController {

    private let titleText: String

    init(titleText: String) {
        self.titleText = titleText
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.titleText = ""
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = titleText

        let label = UILabel()
        label.text = titleText
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor.label

        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

