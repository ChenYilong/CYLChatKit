//
//  CYLDemoUserGroupCell.swift
//  Translated from Objective-C.
//

import UIKit
import CYLChatKit

@objc(CYLDemoUserGroupCellDelegate)
protocol CYLDemoUserGroupCellDelegate: AnyObject {
    func userGroupCellDidSelectUser(_ user: CYLUserDelegate)
    func userGroupCellAddUserButtonDown(withOperationType operationType: CYLDemoConversationOperationType)
}

private let USER_CELL_WIDTH: CGFloat = 57
private let USER_CELL_HEIGHT: CGFloat = 75
private let USER_CELL_ROWSPACE: CGFloat = 15
private var USER_CELL_COLSPACE: CGFloat {
    return (UIScreen.main.bounds.size.width - USER_CELL_WIDTH * 4) / 5
}

@objc(CYLDemoUserGroupCell)
final class CYLDemoUserGroupCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: USER_CELL_WIDTH, height: USER_CELL_HEIGHT)
        layout.minimumInteritemSpacing = USER_CELL_COLSPACE
        layout.sectionInset = UIEdgeInsets(top: USER_CELL_ROWSPACE, left: USER_CELL_COLSPACE * 0.9, bottom: USER_CELL_ROWSPACE, right: USER_CELL_ROWSPACE * 0.9)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.white
        view.isScrollEnabled = false
        view.isPagingEnabled = true
        view.dataSource = self
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.scrollsToTop = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    weak var delegate: CYLDemoUserGroupCellDelegate?

    var users: [CYLUserDelegate] = []

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
        contentView.addSubview(collectionView)
        collectionView.register(CYLDemoUserGroupItemCell.self, forCellWithReuseIdentifier: NSStringFromClass(CYLDemoUserGroupItemCell.self))
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if cyl_isCreatorForCurrentGroupConversaton() {
            return users.count + 2
        }
        return users.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CYLDemoUserGroupItemCell.self), for: indexPath) as? CYLDemoUserGroupItemCell else {
            return UICollectionViewCell()
        }
        let operationType: CYLDemoConversationOperationType
        let user: CYLUserDelegate?
        if indexPath.row < users.count {
            user = users[indexPath.row]
            operationType = .none
        } else if indexPath.row == users.count {
            operationType = .add
            user = nil
        } else {
            operationType = .remove
            user = nil
        }
        cell.setUser(user, operationType: operationType)
        cell.clickBlock = { [weak self] user in
            guard let self = self else { return }
            if let user = user, let delegate = self.delegate {
                delegate.userGroupCellDidSelectUser(user)
            } else {
                self.delegate?.userGroupCellAddUserButtonDown(withOperationType: operationType)
            }
        }
        return cell
    }
}
