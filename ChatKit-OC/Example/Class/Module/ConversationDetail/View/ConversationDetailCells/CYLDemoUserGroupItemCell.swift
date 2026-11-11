//
//  CYLDemoUserGroupItemCell.swift
//  Translated from Objective-C.
//

import UIKit
import CYLChatKit
import SDWebImage

@objc enum CYLDemoConversationOperationType: Int {
    case none
    case add
    case remove
}

@objc(CYLDemoUserGroupItemCell)
final class CYLDemoUserGroupItemCell: UICollectionViewCell {

    /// The user shown by this cell (any core user object).
    private(set) var user: CYLUserDelegate?

    var clickBlock: ((CYLUserDelegate?) -> Void)?

    private let avatarView: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5.0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "CYLDemoUserGroupAvatarButton"
        return button
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        avatarView.addTarget(self, action: #selector(avatarButtonDown), for: .touchUpInside)
        contentView.addSubview(avatarView)
        contentView.addSubview(usernameLabel)
        addConstraints()
    }

    func setUser(_ user: CYLUserDelegate?) {
        setUser(user, operationType: .none)
    }

    func setUser(_ user: CYLUserDelegate?, operationType: CYLDemoConversationOperationType) {
        self.user = user
        if let user = user {
            avatarView.sd_setImage(with: user.avatarURL, for: .normal, placeholderImage: UIImage(named: CYLDEMO_DEFAULT_AVATAR_PATH))
            let displayName: String? = user.name ?? user.clientId
            usernameLabel.text = displayName
            avatarView.accessibilityLabel = displayName
        } else {
            let normalImageName = (operationType == .remove) ? "chatdetail_remove_member" : "chatdetail_add_member"
            let highlightedImageName = (operationType == .remove) ? "chatdetail_remove_memberHL" : "chatdetail_add_memberHL"
            avatarView.setImage(UIImage(named: normalImageName), for: .normal)
            avatarView.setImage(UIImage(named: highlightedImageName), for: .highlighted)
            usernameLabel.text = nil
            avatarView.accessibilityLabel = nil
        }
    }

    // MARK: - Event Response

    @objc private func avatarButtonDown() {
        clickBlock?(user)
    }

    // MARK: - Private Methods

    private func addConstraints() {
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor),
            avatarView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            avatarView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            avatarView.heightAnchor.constraint(equalTo: avatarView.widthAnchor),

            usernameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            usernameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            usernameLabel.leftAnchor.constraint(lessThanOrEqualTo: contentView.leftAnchor),
            usernameLabel.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor)
        ])
    }
}
