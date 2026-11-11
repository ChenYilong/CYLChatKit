//
//  CYLDemoContactListController.swift
//  ChatKit-OC
//
//  Translated from Objective-C (CYLDemoContactListController.h/.m).
//

import UIKit
import CYLChatKit
import CYLTabBarController

@objc(CYLDemoContactListMode)
enum CYLDemoContactListMode: UInt {
    case normal
    case singleSelection
    case multipleSelection
}

@objc(CYLDemoContactListControllerDelegate)
protocol CYLDemoContactListControllerDelegate: NSObjectProtocol {
    func contactListController(_ controller: CYLDemoContactListController, didSelectPeerIds peerIds: [Any])
}

private let CYLDemoContactListControllerIdentifier = "CYLDemoContactListControllerIdentifier"

@objc(CYLDemoContactListController)
final class CYLDemoContactListController: CYLChatBaseTableViewController {

    var mode: CYLDemoContactListMode = .normal
    var excludedPersonIDs: [Any]?
    weak var delegate: CYLDemoContactListControllerDelegate?

    private var cachedSections: [String: [String]]?
    private var cachedSortedSectionTitles: [String]?

    // MARK: - UIViewController Life

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "联系人"
        tableView.register(UINib(nibName: "CYLDemoContactCell", bundle: nil),
                           forCellReuseIdentifier: CYLDemoContactListControllerIdentifier)
        tableView.separatorColor = UIColor(white: 1.0 * CGFloat(0xdf) / CGFloat(0xff), alpha: 1.0)
        tableView.sectionIndexBackgroundColor = UIColor.clear
        navigationItem.title = "联系人"

        if mode == .normal {
            navigationItem.title = "联系人"
            // TODO: a search button on the left.
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登出",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(signOut))
        } else {
            navigationItem.title = "选择联系人"
            let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                 target: self,
                                                 action: #selector(doneBarButtonItemPressed(_:)))
            navigationItem.rightBarButtonItem = doneButtonItem
            tableView.setEditing(true, animated: false)
        }
    }

    @objc private func signOut() {
        CYLDemoUtil.showProgressText("close client ...", duration: 10.0)
        CYLDemoChatKitExample.invokeThisMethodBeforeLogoutSuccess({
            CYLDemoUtil.hideProgress()
            let loginViewController = CYLDemoLoginViewController()
            loginViewController.setClientIDHandler { clientID in
                UserDefaults.standard.set(clientID, forKey: CYLDEMO_KEY_USERID)
                CYLDemoChatKitExample.invokeThisMethodAfterLoginSuccess(withClientId: clientID, success: {
                    let tabBarControllerConfig = CYLDemoTabBarControllerConfig()
                    self.cyl_tabBarController?.rootWindow().rootViewController = tabBarControllerConfig.tabBarController
                }, failed: { _ in
                })
            }
            self.present(loginViewController, animated: true, completion: nil)
        }, failed: { _ in
            CYLDemoUtil.hideProgress()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if presentingViewController != nil {
            let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                   target: self,
                                                   action: #selector(cancelBarButtonItemPressed(_:)))
            navigationItem.leftBarButtonItem = cancelButtonItem
        }

        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cachedSections = nil
        cachedSortedSectionTitles = nil
    }

    // MARK: - tableview

    @objc
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sortedSectionTitles.count
    }

    @objc
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKey = sortedSectionTitles[section]
        return sections[sectionKey]?.count ?? 0
    }

    @objc
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }

    @objc
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CYLDemoContactListControllerIdentifier, for: indexPath) as! CYLDemoContactCell
        let sectionKey = sortedSectionTitles[indexPath.section]
        let peerId = sections[sectionKey]?[indexPath.row] ?? ""
        cell.identifier = peerId
        var name: NSString?
        var avatarURL: NSURL?
        CYLChatKit.sharedInstance().getCachedProfileIfExists(peerId, name: &name, avatarURL: &avatarURL, error: nil)
        var displayName = name as String?
        let avatorURL = avatarURL as URL?
        if displayName == nil || avatorURL == nil {
            displayName = peerId
            CYLChatKit.sharedInstance().getProfileInBackground(forUserId: peerId, callback: { [weak self, weak cell] user, error in
                guard let self = self, let cell = cell else {
                    return
                }
                if error == nil, cell.identifier == user?.userId {
                    guard let indexPath_ = self.tableView.indexPath(for: cell) else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [indexPath_], with: .none)
                    }
                }
            })
        }
        let subTitle = "UserId:\(peerId)"
        cell.configure(withAvatorURL: avatorURL, title: displayName, subtitle: subTitle)
        return cell
    }

    @objc
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedSectionTitles[section]
    }

    @objc
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sortedSectionTitles
    }

    @objc
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if mode == .multipleSelection {
            return
        }
        if mode == .singleSelection {
            // Deselect the cells that were selected before.
            var selectedRows = tableView.indexPathsForSelectedRows ?? []
            selectedRows.removeAll { $0 == indexPath }
            for selectedRow in selectedRows {
                tableView.deselectRow(at: selectedRow, animated: false)
            }
        }
        let sectionKey = sortedSectionTitles[indexPath.section]
        let peerId = sections[sectionKey]?[indexPath.row] ?? ""
        CYLDemoChatKitExample.exampleOpenConversationViewController(withPeerId: peerId,
                                                                    fromNavigationController: tabBarController?.navigationController)
    }

    @objc
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    @objc
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if mode == .multipleSelection || mode == .singleSelection {
            // `Insert | Delete` (3) is the multi-selection control. It is not a named case of the Swift enum.
            return UITableViewCell.EditingStyle(rawValue: UITableViewCell.EditingStyle.insert.rawValue | UITableViewCell.EditingStyle.delete.rawValue)!
        }
        return .delete
    }

    @objc
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if mode == .normal {
            let sectionKey = sortedSectionTitles[indexPath.section]
            guard var array = sections[sectionKey] else {
                return
            }
            let peerId = array[indexPath.row]
            if editingStyle == .delete {
                // TODO: Add Alert
                _ = CYLDemoContactManager.defaultManager().removeContact(forPeerId: peerId)
                array.remove(at: indexPath.row)
                cachedSections?[sectionKey] = array
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }

    // MARK: - Data

    private var sections: [String: [String]] {
        if let cachedSections = cachedSections {
            return cachedSections
        }
        var sections: [String: [String]] = [:]
        let personIDs = CYLDemoContactManager.defaultManager().fetchContactPeerIds().compactMap { $0 as? String }
        for userID in personIDs {
            if let excluded = excludedPersonIDs, excluded.contains(where: { ($0 as? String) == userID }) {
                continue
            }
            let indexKey = indexTitle(forName: userID)
            sections[indexKey, default: []].append(userID)
        }
        cachedSections = sections
        return sections
    }

    private var sortedSectionTitles: [String] {
        if let cachedSortedSectionTitles = cachedSortedSectionTitles {
            return cachedSortedSectionTitles
        }
        let titles = sections.keys.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        cachedSortedSectionTitles = titles
        return titles
    }

    private func indexTitle(forName name: String) -> String {
        let otherKey = "#"
        let mutableString = NSMutableString(string: String(name.prefix(1)))
        CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformStripCombiningMarks, false)

        let key = String((mutableString as String).uppercased().prefix(1))
        if let capital = key.unicodeScalars.first, capital.value >= 65 && capital.value <= 90 {
            return key
        }
        return otherKey
    }

    @objc private func cancelBarButtonItemPressed(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func doneBarButtonItemPressed(_ sender: Any?) {
        var selectedIDs: [String] = []
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            let sectionKey = sortedSectionTitles[indexPath.section]
            if let personId = sections[sectionKey]?[indexPath.row] {
                selectedIDs.append(personId)
            }
        }
        delegate?.contactListController(self, didSelectPeerIds: selectedIDs)
        dismiss(animated: true, completion: nil)
    }

    // TODO: search button, see the Objective-C history of this file.
    func refresh() {
        // TODO: add refresh
    }
}
