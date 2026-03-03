import UIKit

struct ChatHistoryItem {
    let id: String
    let type: CreationType
    let preview: String
    let date: Date
}

final class HistoryViewController: UIViewController {

    private let tabBarBottomInset: CGFloat = 88

    private var chatHistory: [ChatHistoryItem] = [
        ChatHistoryItem(id: "1", type: .rhyme, preview: "Create a rhyme about...", date: Date().addingTimeInterval(-3600)),
        ChatHistoryItem(id: "2", type: .poem, preview: "Write a poem about love...", date: Date().addingTimeInterval(-7200)),
        ChatHistoryItem(id: "3", type: .quatrain, preview: "A quatrain about nature...", date: Date().addingTimeInterval(-86400))
    ]

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = ""
        view.backgroundColor = .clear
        view.insertSubview(BackgroundGradientView(frame: view.bounds), at: 0)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.reuseId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarBottomInset, right: 0)
        tableView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBarBottomInset, right: 0)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func themeDidChange() {
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.subviews.first?.frame = view.bounds
    }
}

// MARK: - UITableViewDataSource & Delegate

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.reuseId, for: indexPath) as! HistoryCell
        cell.configure(with: chatHistory[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = chatHistory[indexPath.row]
        let chatVC = ChatViewController()
        chatVC.creationType = item.type
        navigationController?.pushViewController(chatVC, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            self.chatHistory.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        delete.image = UIImage(systemName: "trash.fill")
        delete.backgroundColor = UIColor(red: 0.9, green: 0.25, blue: 0.25, alpha: 1)
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
