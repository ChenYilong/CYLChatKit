//
//  CYLDemoGroupConversationMemberInfoViewController.swift
//  Translated from Objective-C.
//

import UIKit
import AVOSCloudIM
import MBProgressHUD

private final class CYLDemoGroupConversationMemberInfoModel {
    var memberId: String = ""
    var role: AVIMConversationMemberRole = .member
}

@objc(CYLDemoGroupConversationMemberInfoViewController)
final class CYLDemoGroupConversationMemberInfoViewController: UITableViewController {

    var conversation: AVIMConversation!

    private var members: [String] = []
    private var memberInfos: [String: CYLDemoGroupConversationMemberInfoModel] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "群成员信息"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        members = conversation.members ?? []
        memberInfos = [:]

        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        conversation.getAllMemberInfo(withIgnoringCache: true) { [weak self] infos, error in
            hud?.hide(true)
            guard let self = self else { return }
            if let error = error {
                self.presentErrorAlert(error)
            } else {
                var dict: [String: CYLDemoGroupConversationMemberInfoModel] = [:]
                for info in infos ?? [] {
                    if let memberId = info.memberId() {
                        let model = CYLDemoGroupConversationMemberInfoModel()
                        model.memberId = memberId
                        model.role = info.role()
                        dict[memberId] = model
                    }
                }
                self.memberInfos = dict
                self.tableView.reloadData()
            }
        }
    }

    private func presentErrorAlert(_ error: Error) {
        let alert = UIAlertController(title: "error", message: "\((error as NSError).description)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if cell.detailTextLabel == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        let memberId = members[indexPath.row]
        cell.textLabel?.text = memberId
        if let memberInfo = memberInfos[memberId] {
            switch memberInfo.role {
            case .owner:
                cell.detailTextLabel?.text = "Owner"
            case .manager:
                cell.detailTextLabel?.text = "Manager"
            case .member:
                cell.detailTextLabel?.text = "Member"
            default:
                cell.detailTextLabel?.text = "Member"
            }
        } else {
            cell.detailTextLabel?.text = "Member"
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let memberId = members[indexPath.row]
        let alert = UIAlertController(title: "Change Role", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        let updateRole: (AVIMConversationMemberRole) -> Void = { [weak self] role in
            guard let self = self else { return }
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.conversation.updateMemberRole(withMemberId: memberId, role: role) { [weak self] _, error in
                hud?.hide(true)
                guard let self = self else { return }
                if let error = error {
                    self.presentErrorAlert(error)
                } else {
                    if let model = self.memberInfos[memberId] {
                        model.role = role
                    } else {
                        let model = CYLDemoGroupConversationMemberInfoModel()
                        model.memberId = memberId
                        model.role = role
                        self.memberInfos[memberId] = model
                    }
                    self.tableView.reloadData()
                }
            }
        }
        alert.addAction(UIAlertAction(title: "Member", style: .default, handler: { _ in
            updateRole(.member)
        }))
        alert.addAction(UIAlertAction(title: "Manager", style: .default, handler: { _ in
            updateRole(.manager)
        }))
        present(alert, animated: true, completion: nil)
    }
}
