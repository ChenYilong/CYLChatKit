//
//  CYLDemoLoginViewController.swift
//  ChatKit-OC
//
//  Translated from Objective-C (CYLDemoLoginViewController.h/.m). The view is loaded from
//  CYLDemoLoginViewController.xib (File's Owner: CYLDemoLoginViewController).
//

import UIKit
import QuartzCore
import SDWebImage
import MLPAutoCompleteTextField
import CYLChatKit

typealias CYLDemoClientIDHandler = (String) -> Void

@objc(CYLDemoLoginViewController)
final class CYLDemoLoginViewController: UIViewController, UITextFieldDelegate, MLPAutoCompleteTextFieldDelegate {

    /// Outlet of the nib. The nib's object is a `CYLDemoLoginDataSource`, which is not a `CYLDemoDataSource`, so the
    /// outlet is typed `NSObject`; the controller never reads it.
    @IBOutlet var autocompleteDataSource: NSObject!
    @IBOutlet weak var autocompleteTextField: MLPAutoCompleteTextField!
    @IBOutlet var demoTitle: UILabel!
    @IBOutlet var author: UILabel!
    /// When true, logs in with the last saved client ID on launch (AppDelegate sets it).
    var autoLogin = false

    private(set) var clientIDHandler: CYLDemoClientIDHandler?

    func setClientIDHandler(_ clientIDHandler: CYLDemoClientIDHandler?) {
        self.clientIDHandler = clientIDHandler
    }

    override func viewWillAppear(_ animated: Bool) {
        // Like the Objective-C version, this does not call super.
        view.alpha = 0
        UIView.animate(withDuration: 0.2, delay: 0.25, options: .curveEaseOut, animations: {
            self.view.alpha = 1.0
        }, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Fill in the client ID saved by the last login.
        let clientId = UserDefaults.standard.string(forKey: CYLDEMO_KEY_USERID)
        autocompleteTextField.text = clientId
        // Localized text (the nib holds only a Chinese placeholder) and the VoiceOver label for the field.
        demoTitle.text = CYLDemoExampleLocalizedString("login.title", "Enter any ClientID to start chatting")
        autocompleteTextField.accessibilityLabel = CYLDemoExampleLocalizedString("login.clientid", "Client ID")
        autocompleteTextField.accessibilityHint = CYLDemoExampleLocalizedString("login.clientid.hint", "")
        autocompleteTextField.accessibilityIdentifier = "CYLDemoLoginClientIdTextField"
        autocompleteTextField.borderStyle = .roundedRect
        // CI screenshots keep the keyboard (and its first-run swipe-typing introduction) off the screen.
        if !UserDefaults.standard.bool(forKey: "CYLDemoScreenshots") {
            autocompleteTextField.becomeFirstResponder()
        }
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: autocompleteTextField)
        autocompleteTextField.autoCompleteTableViewHidden = false
        if autoLogin, let clientId = clientId, !clientId.isEmpty {
            clientIDHandler?(clientId)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        clientIDHandler?(textField.text ?? "")
        return true
    }

    // MARK: - MLPAutoCompleteTextField Delegate
    // The Objective-C selectors are spelled out so the delegate is found at run time whatever Swift name the importer
    // gives these methods.

    @objc(autoCompleteTextField:shouldConfigureCell:withAutoCompleteString:withAttributedString:forAutoCompleteObject:forRowAtIndexPath:)
    func autoCompleteTextField(_ textField: MLPAutoCompleteTextField!,
                               shouldConfigureCell cell: UITableViewCell!,
                               withAutoComplete autocompleteString: String!,
                               with boldedString: NSAttributedString!,
                               forAutoComplete autocompleteObject: MLPAutoCompletionObject!,
                               forRowAt indexPath: IndexPath!) -> Bool {
        // This is your chance to customize an autocomplete table view cell before it appears.
        var avatorURL: URL?
        for user in CYLDemoContactProfiles {
            if autocompleteString == user[CYLDemoProfileKeyPeerId] {
                avatorURL = URL(string: user[CYLDemoProfileKeyAvatarURL] ?? "")
            }
        }
        let image = UIImage(named: "image_placeholder")
        cell.imageView?.sd_setImage(with: avatorURL, placeholderImage: image)
        return true
    }

    @objc(autoCompleteTextField:didSelectAutoCompleteString:withAutoCompleteObject:forRowAtIndexPath:)
    func autoCompleteTextField(_ textField: MLPAutoCompleteTextField!,
                               didSelectAutoComplete selectedString: String!,
                               withAutoComplete selectedObject: MLPAutoCompletionObject!,
                               forRowAt indexPath: IndexPath!) {
        clientIDHandler?(selectedString)
    }

    @objc(autoCompleteTextField:willHideAutoCompleteTableView:)
    func autoCompleteTextField(_ textField: MLPAutoCompleteTextField!, willHideAutoCompleteTableView autoCompleteTableView: UITableView!) {
        NSLog("Autocomplete table view will be removed from the view hierarchy")
    }

    @objc(autoCompleteTextField:willShowAutoCompleteTableView:)
    func autoCompleteTextField(_ textField: MLPAutoCompleteTextField!, willShowAutoComplete autoCompleteTableView: UITableView!) {
        NSLog("Autocomplete table view will be added to the view hierarchy")
    }

    @objc(autoCompleteTextField:didHideAutoCompleteTableView:)
    func autoCompleteTextField(_ textField: MLPAutoCompleteTextField!, didHideAutoCompleteTableView autoCompleteTableView: UITableView!) {
        NSLog("Autocomplete table view ws removed from the view hierarchy")
    }

    @objc(autoCompleteTextField:didShowAutoCompleteTableView:)
    func autoCompleteTextField(_ textField: MLPAutoCompleteTextField!, didShowAutoCompleteTableView autoCompleteTableView: UITableView!) {
        NSLog("Autocomplete table view was added to the view hierarchy")
    }
}
