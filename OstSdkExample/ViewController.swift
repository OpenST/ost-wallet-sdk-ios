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
        
//        _ = try! OstKeyManager(userId: "123").createKeyWithMnemonics()
//        _ = try! OstKeyManager(userId: "123").createAPIKey()
//        let a = try! OstKeyManager(userId: "123").getEthereumKey(forAddresss: "0x72A1ade35F9dB59e150f01c62F0ae17cBd0133D9")
//        let b = try! OstKeyManager(userId: "123").getAPIKey()
//        let c = try! OstKeyManager(userId: "123").getDeviceAddress()
//        let d = try! OstKeyManager(userId: "123").getAPIAddress()        
    }
    
//    Using mainnet network
//    PrivateKey is a09e1c89ce1a424ad95678ad2717f5666f2c70c78a40066b83cf43f366d48ab3
//    PublicKey is 04270cfbd5a901d46730721e99abb9fffc28f93b7c49c809eebfcc51765bb551fae9aa2d638404670ac5f94e39068b62df143f4d1f75d493250e84e54465b38b7a
//    Address is 0x72A1ade35F9dB59e150f01c62F0ae17cBd0133D9 
    
//    Using mainnet network
//    PrivateKey is 8c80fdadb87ab839b3d9d2cbd953cfd37a47dacb7cd8a43d2f98b0c0027f93b9
//    PublicKey is 04cc1e8934eb60819a0ffa4f9841cc54cc83049213988fcc065072cd59773b20e3715ac7614b1296ade2c6c322c5d15863ae1fc0a024760642b43a7f4c609c828f
//    Address is 0xc0e8db0Fdfd256A663763A2152f9b5E6B4033403 
}
