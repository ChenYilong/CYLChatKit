//
//  CYLDemoProfileNameEditViewController.swift
//  Translated from Objective-C.
//

import UIKit
import FXForms

@objc(CYLDemoProfileNameEditViewControllerDelegate)
protocol CYLDemoProfileNameEditViewControllerDelegate: AnyObject {
    func profileNameDidChanged(_ name: String)
}

@objc(CYLDemoNameForm)
final class CYLDemoNameForm: NSObject, FXForm {

    @objc var name: String?

    @objc func fields() -> [Any] {
        return [[FXFormFieldKey: "name", FXFormFieldTitle: "群聊名称"]]
    }

    @objc func extraFields() -> [Any] {
        return [[FXFormFieldTitle: "保存", FXFormFieldHeader: "", FXFormFieldAction: "onSaveCellClick:"]]
    }
}

@objc(CYLDemoProfileNameEditViewController)
final class CYLDemoProfileNameEditViewController: FXFormViewController {

    @objc var placeholderName: String?

    weak var delegate: CYLDemoProfileNameEditViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.cylDemoColorGrayBG()
        let nameForm = CYLDemoNameForm()
        nameForm.name = placeholderName
        formController.form = nameForm
    }

    /// FXForms sends the tapped cell, which conforms to its cell protocol; its `field` is read through key-value coding.
    @objc func onSaveCellClick(_ sender: UITableViewCell) {
        guard let field = sender.value(forKey: "field") as? NSObject,
              let nameForm = field.value(forKey: "form") as? CYLDemoNameForm else { return }
        if nameForm.name == placeholderName {
            navigationController?.popViewController(animated: true)
            return
        }
        if let name = nameForm.name, name.count > 0 {
            navigationController?.popViewController(animated: true)
            delegate?.profileNameDidChanged(name)
            return
        }
    }
}
