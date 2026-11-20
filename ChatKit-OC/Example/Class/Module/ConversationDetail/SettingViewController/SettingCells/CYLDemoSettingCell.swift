//
//  CYLDemoSettingCell.swift
//  Translated from Objective-C.
//

import UIKit
import SDWebImage

@objc(CYLDemoSettingCell)
final class CYLDemoSettingCell: UITableViewCell {

    var item: CYLDemoSettingItem? {
        didSet {
            applyItem()
        }
    }

    private let titleLabel = UILabel()

    private let rightLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 15.0)
        return label
    }()

    private let rightImageView = UIImageView()

    /// Trailing constraint of `rightLabel`; its constant switches with the disclosure indicator.
    private var rightLabelTrailing: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(rightLabel)
        contentView.addSubview(rightImageView)
        addConstraints()
    }

    private func applyItem() {
        guard let item = item else { return }
        titleLabel.text = item.title
        rightLabel.text = item.subTitle
        if let path = item.rightImagePath {
            rightImageView.image = UIImage(named: path)
        } else if let urlString = item.rightImageURL {
            rightImageView.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: CYLDEMO_DEFAULT_AVATAR_PATH))
        } else {
            rightImageView.image = nil
        }

        if item.showDisclosureIndicator == false {
            accessoryType = .none
            rightLabelTrailing?.constant = -15.0
        } else {
            accessoryType = .disclosureIndicator
            rightLabelTrailing?.constant = 0
        }

        selectionStyle = item.disableHighlight ? .none : .default
    }

    // MARK: - Private Methods

    private func addConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightImageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(500), for: .horizontal)
        rightLabel.setContentCompressionResistancePriority(UILayoutPriority(200), for: .horizontal)

        let trailing = rightLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        rightLabelTrailing = trailing

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),

            trailing,
            rightLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            rightLabel.leftAnchor.constraint(greaterThanOrEqualTo: titleLabel.rightAnchor, constant: 20),

            rightImageView.rightAnchor.constraint(equalTo: rightLabel.leftAnchor, constant: -2),
            rightImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
