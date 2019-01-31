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

    @IBOutlet weak var textView: UITextView!
   
    @IBAction func signTxTapped(_ sender: Any) {
        signTransaction()
    }
    @IBAction func eip1077Tapped(_ sender: Any) {
        signEIP1077()
    }
    
    @IBAction func createEntitiesTapped(_ sender: Any) {
        testInitUser()
        testInitMultiSigWallet()
        testInitMultiSig()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

//        qrCode()
//        privateKeyStore()
//        privateKeyGet()
//        storePrivateKeySync()
        
//        testInitUser()
//        testInitMultiSigWallet()
//        testInitMultiSig()
//        testKeyGenerationProcess()
        
}
    
    func qrCode() {
        
        let string: String = "{so:12,sd:{ad:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c,sl:800000000000000000000000000000000000000000,eh 1000000000000000000000000,ad1:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c,sl1:800000000000000000000000000000000000000000,eh1:1000000000000000000000000,ad2:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c,sl2:800000000000000000000000000000000000000000,eh2:1000000000000000000000000,ad3:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c,sl3:800000000000000000000000000000000000000000,eh3:1000000000000000000000000},sn:{0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c:0x22cd7c22936440880aaca015a28b6c94a256edb8315c73743482ce4efb9afdfa2776fdcce124ca4f0334f6748afe910c3beda4063d38055e1716cbe2c551059f1b,0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c41:0x22cd7c22936440880aaca015a28b6c94a256edb8315c73743482ce4efb9afdfa2776fdcce124ca4f0334f6748afe910c3beda4063d38055e1716cbe2c551059f1b,0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c42:0x22cd7c22936440880aaca015a28b6c94a256edb8315c73743482ce4efb9afdfa2776fdcce124ca4f0334f6748afe910c3beda4063d38055e1716cbe2c551059f1b,0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c43:0x22cd7c22936440880aaca015a28b6c94a256edb8315c73743482ce4efb9afdfa2776fdcce124ca4f0334f6748afe910c3beda4063d38055e1716cbe2c551059f1b,0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c44:0x22cd7c22936440880aaca015a28b6c94a256edb8315c73743482ce4efb9afdfa2776fdcce124ca4f0334f6748afe910c3beda4063d38055e1716cbe2c551059f1b},ed:0xaf24f7c70000000000000000000000005a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c0000000000000000000000005a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c0000000000000000000000005a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c0000000000000000000000005a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c000}||{so:12,sd:{ad:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c,sl:800000000000000000000000000000000000000000,eh 1000000000000000000000000,ad1:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c,sl1:800000000000000000000000000000000000000000,eh1:1000000000000000000000000,ad2:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c,sl2:800000000000000000000000000000000000000000,eh2:1000000000000000000000000,ad3:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c,sl3:800000000000000000000000000000000000000000,eh3:1000000000000000000000000},sn:{0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c:0x22cd7c22936440880aaca015a28b6c94a256edb8315c73743482ce4efb9afdfa2776fdcce124ca4f0334f6748afe910c3beda4063d38055e1716cbe2c551059f1b,0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c41:0x22cd7c22936440880aaca015a28b6c94a256edb8315c73743482ce4efb9afdfa2776fdcce124ca4f0334f6748afe910c3beda4063d38055e1716cbe2c551059f1b,0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c42:0x22cd7c22936440880aaca015a28b6c94a256edb8315c73743482ce4efb9afdfa2776fdcce124ca4f0334f6748afe910c3beda4063d38055e1716cbe2c551059f1b,0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c43:0x22cd7c22936440880aaca015a28b6c94a256edb8315c73743482ce4efb9afdfa2776fdcce124ca4f0334f6748afe910c3beda4063d38055e1716cbe2c551059f1b,0x5a0b54d5dc17e0aadc383d2db431234567890123456789012345678901234567890123456"
        guard let ciImage: CIImage = string.qrCode else {
            print("CIImage is not generated.")
            return
        }
        let qrImage: UIImage = UIImage(ciImage: ciImage)
        
        print(qrImage.readQRCode!)
    }
    
    func privateKeyGet() {
        do {
            let suffix = "9"
            guard let secKey = try OstSecureKey.getSecKey(for: "0x\(suffix)") else {
                return
            }
            print( String(data: secKey.secData, encoding: .utf8) ?? "unable to convert")
        }catch {
            
        }
    }
    
    func storePrivateKeySync() {
        let suffix = "10"
        let key = "0x\(suffix)"
        let privateKey: String = "506e6644af3b5b4e044544e9179ad7ac3097d3c3b870907b99587a2841711b3\(suffix)"
        do {
            let secureKey = try OstSecureKey.storeSecKeySync(privateKey, forKey: key)
//            print( String(data: secureKey!.secData, encoding: .utf8) ?? "unable to convert")
            
            guard let secKey = try OstSecureKey.getSecKey(for: key) else {
                return
            }
            print( String(data: secKey.secData, encoding: .utf8) ?? "unable to convert")
            
        }catch let error{
            print (error)
        }
    }
    
    
    //*********************************** wallet sign test *****************************
    
    func testInitUser() {
        //create user
        let userDict = ["id": "1a",
                        "token_holder_id": "1a",
                        "multisig_id": "1a",
                        "economy_id" : "1a",
                        "uts" : "123"] as [String : Any]
        OstSdk.initUser(userDict, success: { (user) in
            
        }, failure: nil)
    }
    
    func testKeyGenerationProcess() {
        do {
            let wallet =  try OstKeyGenerationProcess().perform()
            print(wallet.address!)
            print(wallet.publicKey!)
        }catch let error{
            print(error)
        }
    }
    
    func testInitMultiSig() {
        let multiSig: [String: Any] = ["id":"1a",
                                       "user_id": "1a",
                                       "address": "0x82A1992f5473bDdFFa8253A3733Ad34971b5f1fa",
                                       "token_holder_id": "1a",
                                       "wallets": ["1a","2a","3a"],
                                       "requirement": "1",
                                       "authorize_session_callprefix": "0x",
                                       "uts" : "123"]
        OstSdk.initMultiSig(multiSig, success: { (multiSig) in
            
        }, failure: { (error) in
            print(error)
        })
    }
    
    func testInitMultiSigWallet() {
        let multiSigWallet: [String: Any] = ["id": "1a",
                                             "parent_id": "1a",
                                             "local_entity_id": -1,
                                             "address": "0x82A1992f5473bDdFFa8253A3733Ad34971b5f1fa",
                                             "multi_sig_id": "1a",
                                             "nonce": "0",
                                             "uts" : "123"]
        OstSdk.initMultiSigWallet(multiSigWallet, success: { (multiSigWallet) in
            
        }, failure: { (error) in
            print(error)
        })
    }
    
    func signTransaction() {
        do {
            let user: OstUser? = try OstSdk.getUser("1a")
            guard let multiSig: OstMultiSig = try user?.getMultiSig() else {
                return
            }
            guard let multiSigWallet: OstMultiSigWallet = try multiSig.getDeviceMultiSigWallet() else {
                return
            }
            
            let tx = try OstMultiSigWallet.Transaction(nonce: 1, value: "10000", to: "0x82A1992f5473bDdFFa8253A3733Ad34971b5f1fa", gasPrice: 21000, gasLimit: 42000)
            
            let output = try multiSigWallet.signTransaction(tx)
            self.textView.text = output
            
        }catch let error{
            print(error)
            self.textView.text = error.localizedDescription
        }
    }
    
    func signEIP1077(){
        let tx = OstTokenHolderSession.Transaction(from: "0x5a85a1E5a749A76dDf378eC2A0a2Ac310ca86Ba8")
        tx.value = 1
        tx.to = "0xF281e85a0B992efA5fda4f52b35685dC5Ee67BEa"
        tx.gas = 0
        tx.gasPrice = 0
        tx.data = "0xF281e85a0B992efA5fda4f52b35685dC5Ee67BEa"
        tx.txnCallPrefix = "0x0"
        tx.nonce = 1
        
        do {
        let tokenHolderSession = try OstTokenHolderSession(["id": 1, "address": "0xbb289Df28775EED3AD80Ad56086DFB4c62fAf43B"])
            let output = try tokenHolderSession.signTransaction(tx)
            self.textView.text = output
        }catch let error {
            print(error)
            self.textView.text = error.localizedDescription
        }
    }
}
