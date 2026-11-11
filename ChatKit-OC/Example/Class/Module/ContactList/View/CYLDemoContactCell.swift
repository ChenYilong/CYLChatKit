//
//  CYLDemoContactCell.swift
//  ChatKit-OC
//
//  Translated from Objective-C (CYLDemoContactCell.h/.m). The cell is loaded from CYLDemoContactCell.xib.
//

import UIKit
import SDWebImage
import CYLChatKit

@objc(CYLDemoContactCell)
final class CYLDemoContactCell: UITableViewCell {

    @IBOutlet private weak var avatorImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    var identifier: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        if let avatarImageViewCornerRadiusBlock = CYLChatKit.sharedInstance().avatarImageViewCornerRadiusBlock {
            let avatarImageViewCornerRadius = avatarImageViewCornerRadiusBlock(avatorImageView.frame.size)
            avatorImageView.cyl_cornerRadiusAdvance(avatarImageViewCornerRadius, rectCornerType: .allCorners)
        }
    }

    func configure(withAvatorURL avatorURL: URL?, title: String?, subtitle: String?) {
        let imageName = "Placeholder_Avator"
        let imageNameWithBundlePath = "Placeholder.bundle/\(imageName)"
        let avatorImage = UIImage(named: imageNameWithBundlePath)
        avatorImageView.sd_setImage(with: avatorURL, placeholderImage: avatorImage)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        if (subtitle ?? "").isEmpty {
            subtitleLabel.removeFromSuperview()
        }
    }
}
