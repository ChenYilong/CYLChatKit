//
//  CYLDemoSettingViewController.swift
//  Translated from Objective-C.
//

import UIKit
import CYLChatKit
import AVOSCloudIM

let HEIGHT_SETTING_CELL: CGFloat = 44.0
let HEIGHT_SETTING_TOP_SPACE: CGFloat = 15.0
let HEIGHT_SETTING_BOTTOM_SPACE: CGFloat = 12.0

@objc(CYLDemoSettingViewController)
class CYLDemoSettingViewController: UITableViewController, CYLDemoSettingSwitchCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var data: [CYLDemoSettingGroup] = []

    private var storedAnalyzeTitle: String?
    var analyzeTitle: String? {
        get {
            return storedAnalyzeTitle ?? navigationItem.title
        }
        set {
            storedAnalyzeTitle = newValue
        }
    }

    private(set) lazy var pickerController: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        return picker
    }()

    var conversation: AVIMConversation!

    // MARK: - Life cycle

    override func loadView() {
        let bounds = UIScreen.main.bounds
        view = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: HEIGHT_SETTING_TOP_SPACE))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: HEIGHT_SETTING_BOTTOM_SPACE))
        tableView.backgroundColor = UIColor.cylDemoColorGrayBG()
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        tableView.separatorColor = UIColor.cylDemoColorGrayLine()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CYLDemoSettingHeaderTitleView.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(CYLDemoSettingHeaderTitleView.self))
        tableView.register(CYLDemoSettingFooterTitleView.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(CYLDemoSettingFooterTitleView.self))
        tableView.register(CYLDemoSettingCell.self, forCellReuseIdentifier: NSStringFromClass(CYLDemoSettingCell.self))
        tableView.register(CYLDemoSettingButtonCell.self, forCellReuseIdentifier: NSStringFromClass(CYLDemoSettingButtonCell.self))
        tableView.register(CYLDemoSettingSwitchCell.self, forCellReuseIdentifier: NSStringFromClass(CYLDemoSettingSwitchCell.self))
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = data[indexPath.section].object(at: indexPath.row)
        guard let identifier = item.cellClassName else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell()
        if let settingCell = cell as? CYLDemoSettingCell {
            settingCell.item = item
        } else if let buttonCell = cell as? CYLDemoSettingButtonCell {
            buttonCell.item = item
        } else if let switchCell = cell as? CYLDemoSettingSwitchCell {
            switchCell.item = item
            if item.type == .switch {
                switchCell.delegate = self
            }
        }
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let group = data[section]
        guard let headerTitle = group.headerTitle else {
            return nil
        }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(CYLDemoSettingHeaderTitleView.self)) as? CYLDemoSettingHeaderTitleView
        view?.text = headerTitle
        return view
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let group = data[section]
        guard let footerTitle = group.footerTitle else {
            return nil
        }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(CYLDemoSettingFooterTitleView.self)) as? CYLDemoSettingFooterTitleView
        view?.text = footerTitle
        return view
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HEIGHT_SETTING_CELL
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let group = data[section]
        return 0.5 + (group.headerTitle == nil ? 0 : 5.0 + group.headerHeight)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let group = data[section]
        return 20.0 + (group.footerTitle == nil ? 0 : 5.0 + group.footerHeight)
    }

    // MARK: - CYLDemoSettingSwitchCellDelegate

    func settingSwitchCell(forItem settingItem: CYLDemoSettingItem, didChangeStatus on: Bool, completionHandler: @escaping CYLDemoSettingSwitchCellCompletionhandler) {
        showUnhandledSwitchAlert(for: settingItem, on: on)
    }

    /// Shows the "switch event not handled" alert (UIAlertView is unavailable at runtime on current iOS).
    func showUnhandledSwitchAlert(for settingItem: CYLDemoSettingItem, on: Bool) {
        let message = "Title: \(settingItem.title ?? "(null)")\nStatus: \(on ? "on" : "off")"
        presentSimpleAlert(title: "Switch事件未被子类处理", message: message, buttonTitle: "确定")
    }

    func presentSimpleAlert(title: String?, message: String?, buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        CYLChatKit.sharedInstance().setBackgroundImage(image, forConversationId: conversation.conversationId, scaledToSize: view.frame.size)
        navigationController?.popViewController(animated: false)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func presentSelectMemberViewControllerMemberIds(_ memeberIds: [String], excludedUserIds: [String]?, callback: (([String], Error?) -> Void)?) {
        let users: [CYLUserDelegate] = (try? CYLChatKit.sharedInstance().getCachedProfilesIfExists(memeberIds, shouldSameCount: true)) ?? []

        var excluded = excludedUserIds ?? []
        if let currentClientID = CYLChatKit.sharedInstance().clientId {
            excluded.append(currentClientID)
        }
        let contacts = Set(users.compactMap { ($0 as? NSObject).map { AnyHashable($0) } })
        let excludedSet = Set(excluded.map { AnyHashable($0) })
        let contactListViewController = CYLContactListViewController(contacts: contacts, userIds: Set(memeberIds), excludedUserIds: excludedSet, mode: .multipleSelection)
        contactListViewController.setSelectedContactsCallback { _, peerIds in
            if peerIds.isEmpty { return }
            _ = NSObject.showHUD()
            callback?(peerIds, nil)
        }
        let navigationController = UINavigationController(rootViewController: contactListViewController)
        present(navigationController, animated: true, completion: {})
    }
}
