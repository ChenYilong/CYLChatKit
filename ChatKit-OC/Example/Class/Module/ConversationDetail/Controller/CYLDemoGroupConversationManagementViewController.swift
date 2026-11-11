//
//  CYLDemoGroupConversationManagementViewController.swift
//  Translated from Objective-C.
//

import UIKit
import AVOSCloudIM

@objc(CYLDemoGroupConversationManagementViewController)
final class CYLDemoGroupConversationManagementViewController: UITableViewController {

    var conversation: AVIMConversation!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "群管理"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        if indexPath.row == 0 {
            cell.textLabel?.text = "群成员信息"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let vc = CYLDemoGroupConversationMemberInfoViewController(style: .grouped)
            vc.conversation = conversation
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
