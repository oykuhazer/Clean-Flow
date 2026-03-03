
import UIKit

final class HistoryCell: UITableViewCell {

    static let reuseId = "HistoryCell"

    private let containerView = UIView()
    private let typeLabel = UILabel()
    private let previewLabel = UILabel()
    private let dateLabel = UILabel()
    private let arrowIcon = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false

        typeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        typeLabel.textColor = .white
        typeLabel.translatesAutoresizingMaskIntoConstraints = false

        previewLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        previewLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        previewLabel.numberOfLines = 1
        previewLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        arrowIcon.image = UIImage(systemName: "chevron.right")
        arrowIcon.tintColor = UIColor.white.withAlphaComponent(0.5)
        arrowIcon.contentMode = .scaleAspectFit
        arrowIcon.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(containerView)
        containerView.addSubview(typeLabel)
        containerView.addSubview(previewLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(arrowIcon)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            typeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            typeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            previewLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            previewLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            previewLabel.trailingAnchor.constraint(equalTo: arrowIcon.leadingAnchor, constant: -12),

            dateLabel.topAnchor.constraint(equalTo: previewLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            arrowIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            arrowIcon.widthAnchor.constraint(equalToConstant: 12),
            arrowIcon.heightAnchor.constraint(equalToConstant: 12)
        ])
    }

    func configure(with item: ChatHistoryItem) {
        containerView.backgroundColor = ThemeManager.shared.lightTint()
        typeLabel.text = item.type.rawValue
        previewLabel.text = item.preview
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: item.date)
    }
}
