//
//  CYLDemoSettingFooterTitleView.swift
//  Translated from Objective-C.
//

import UIKit

@objc(CYLDemoSettingFooterTitleView)
final class CYLDemoSettingFooterTitleView: CYLDemoSettingHeaderTitleView {

    override func installTitleLabelConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5.0)
        ])
    }
}
