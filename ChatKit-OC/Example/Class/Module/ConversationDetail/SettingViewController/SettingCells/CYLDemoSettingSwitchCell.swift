//
//  CYLDemoSettingSwitchCell.swift
//  Translated from Objective-C.
//

import UIKit

typealias CYLDemoSettingSwitchCellCompletionhandler = (Bool, Error?) -> Void

@objc(CYLDemoSettingSwitchCellDelegate)
protocol CYLDemoSettingSwitchCellDelegate: AnyObject {
    @objc optional func settingSwitchCell(forItem settingItem: CYLDemoSettingItem, didChangeStatus on: Bool, completionHandler: @escaping CYLDemoSettingSwitchCellCompletionhandler)
}

@objc(CYLDemoSettingSwitchCell)
final class CYLDemoSettingSwitchCell: UITableViewCell {

    weak var delegate: CYLDemoSettingSwitchCellDelegate?

    var item: CYLDemoSettingItem? {
        didSet {
            titleLabel.text = item?.title
            cellSwitch.isOn = item?.isSwithOn ?? false
        }
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var cellSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(switchChangeStatus(_:)), for: .valueChanged)
        return toggle
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        selectionStyle = .none
        accessoryView = cellSwitch
        contentView.addSubview(titleLabel)
        addConstraints()
    }

    // MARK: - Event Response

    @objc private func switchChangeStatus(_ sender: UISwitch) {
        guard let delegate = delegate, let item = item else { return }
        let completionHandler: CYLDemoSettingSwitchCellCompletionhandler = { _, error in
            if error != nil {
                sender.isOn = !sender.isOn
            }
        }
        delegate.settingSwitchCell?(forItem: item, didChangeStatus: sender.isOn, completionHandler: completionHandler)
    }

    // MARK: - Private Methods

    private func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            titleLabel.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -15)
        ])
    }
}
