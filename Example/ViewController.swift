//
//  ViewController.swift
//  Example
//
//  Created by aniket ayachit on 07/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstSdk

class ViewController: UIViewController {
    
    static let notificationName: String = "printOutput"
    static let userId: String = "1231453-43234-3451-412355413"
    static let tokenId: String = "58"
    
    @IBOutlet weak var flowNameLabel: UILabel!
    
    @IBOutlet weak var flowOutputTextView: UITextView!
    @IBOutlet weak var selectAndExecuteFlowButton: UIButton!
    
    let mappyUserId: String = "5c5ad125a5c9b42506d50366"
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        try! initUser()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.printOutput(_:)), name: NSNotification.Name(ViewController.notificationName), object: nil)
    }
    
    func initUser() throws {
        let userEntity = ["user_id": ViewController.userId,
                          "token_id": ViewController.tokenId,
                          "current_timestamp": String(Date().timeIntervalSince1970)]
        let user: OstUser? = try OstSdk.parseUser(userEntity)
        Logger.log(message: "user", parameterToPrint: user?.data)
    }
    
    //MARK: - Button Action
    @IBAction func selectAndExecuteFlowButtonTapped(_ sender: Any) {
        selectAndExecuteFlowButton.isUserInteractionEnabled = false
        showActionSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.selectAndExecuteFlowButton.isUserInteractionEnabled = true
        }
    }

    //MARK: - property setter
    func setFlowName(_ flowName: String) {
        self.flowNameLabel.text = flowName
        printOutput("")
    }
    
    @objc func printOutput(_ output: Any? = nil) {
        if flowOutputTextView != nil {
            do {
                if (output is String) {
                    flowOutputTextView.text = output as? String
                } else if(output is Int) {
                   flowOutputTextView.text = String(output as! Int)
                }else {
                    flowOutputTextView.text = try OstUtils.toJSONString(output as Any)
                }
            }catch {
                flowOutputTextView.text = "output failed to print"
            }
        }else {
            flowOutputTextView.text = "output failed to print"
        }
    }
    
    func showActionSheet() {
        let alert = UIAlertController(title: "Select Flow", message: "Please Select flow to execute", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Register Device", style: .default , handler:{ (UIAlertAction)in
            self.setFlowName(UIAlertAction.title!)
            self.registerDevice()
        }))
        
        alert.addAction(UIAlertAction(title: "Verify Biomatric", style: .default , handler:{ (UIAlertAction)in
            self.setFlowName(UIAlertAction.title!)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
        }))
        
        self.present(alert, animated: true, completion: { })
    }
    
    //MARK: - Flows
    func registerDevice() {
        do {
            try SetupDevice(userId: ViewController.userId, tokenId: ViewController.tokenId, mappyUserId: "").perform()
        }catch let error {
            self.printOutput(error.localizedDescription)
        }
    }
    
    
   
}
