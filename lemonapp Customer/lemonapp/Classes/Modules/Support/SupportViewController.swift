//
//  SupportViewController.swift
//  lemonapp
//
//  Copyright © 2016 11lemons. All rights reserved.
//

import Foundation
import UIKit
import MessageUI


final class SupportViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet fileprivate weak var menuButton: UIBarButtonItem!
    @IBOutlet fileprivate weak var moreButton: UIButton!
    
    @IBOutlet var moreBtnHeight: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    let viewModel = SupportViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeConstraintUnderSafeAreaIfIsIphoneX(constraint: moreBtnHeight, baseValue: 60)
        makeButtonBottomContentInsetIfIsIphoneX(button: moreButton)
        
        viewModel.supportItems.bind(to: tableView) { dataSource, indexPath, tableView in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            if let supportCell = cell as? SupportCell {
                //TODO migration-check
                //TODO tableview-migration
                //Before migration code
                
                supportCell.viewModel = dataSource/*[indexPath.section]*/[indexPath.row]
                return supportCell
            }
            return cell
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        moreButton.fixForwardArrow()
    }
    
    @IBAction func openMenu(_ sender: UIBarButtonItem) {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let supportType = viewModel.supportItems.array[indexPath.row].supportType
        switch supportType {
        case .call:
            if let phone = viewModel.phoneToCall {
                let alert = UIAlertController(title: "(914) 249-9534", message: "", preferredStyle: UIAlertControllerStyle.alert)
                
                let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { _ in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(cancel)
                
                let call = UIAlertAction(title: "Call", style: UIAlertActionStyle.default) { _ in
                    alert.dismiss(animated: true, completion: nil)
                    UIApplication.shared.open(phone as URL, options: [:], completionHandler: nil)
                }
                alert.addAction(call)
                
                present(alert, animated: true, completion: nil)
            }
        case .text:
            let messageController = MFMessageComposeViewController()
            messageController.recipients = [viewModel.phoneToText]
            messageController.messageComposeDelegate = self
            present(messageController, animated: true, completion: nil)
        case .email:
            let messageController = MFMailComposeViewController()
            messageController.setToRecipients([viewModel.phoneToText])
            messageController.mailComposeDelegate = self
            present(messageController, animated: true, completion: nil)
        case .faq:
            self.performSegueWithIdentifier(.FAQ)
        case .privacyPolicy:
            self.performSegueWithIdentifier(.PrivacyPolicy)
        case .termsOrUse:
            self.performSegueWithIdentifier(.TermsOfService)
        }
    }
}


extension SupportViewController: MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
