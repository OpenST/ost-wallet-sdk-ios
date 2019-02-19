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
    }
}
