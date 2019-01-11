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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        qrCode()
//
//        do {
//            try OSTInitialDeviceProvisioning(OSTKeyGenerationParams()).perform()
//        }catch let error{
//            print(error)
//        }
    }
    
    func qrCode() {
        
        let string: String = "{so:12,sd:{ad:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c,sl:800000000000000000000000000000000000000000,eh 1000000000000000000000000,ad1:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c,sl1:800000000000000000000000000000000000000000,eh1:1000000000000000000000000,ad2:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c,sl2:800000000000000000000000000000000000000000,eh2:1000000000000000000000000,ad3:0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c,sl3:800000000000000000000000000000000000000000,eh3:1000000000000000000000000},sn:{0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c:0x22cd7c22936440880aaca015a28b6c94a256edb8315c73743482ce4efb9afdfa2776fdcce124ca4f0334f6748afe910c3beda4063d38055e1716cbe2c551059f1b,0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c41:0x22cd7c22936440880aaca015a28b6c94a256edb8315c73743482ce4efb9afdfa2776fdcce124ca4f0334f6748afe910c3beda4063d38055e1716cbe2c551059f1b,0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c42:0x22cd7c22936440880aaca015a28b6c94a256edb8315c73743482ce4efb9afdfa2776fdcce124ca4f0334f6748afe910c3beda4063d38055e1716cbe2c551059f1b,0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c43:0x22cd7c22936440880aaca015a28b6c94a256edb8315c73743482ce4efb9afdfa2776fdcce124ca4f0334f6748afe910c3beda4063d38055e1716cbe2c551059f1b,0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c44:0x22cd7c22936440880aaca015a28b6c94a256edb8315c73743482ce4efb9afdfa2776fdcce124ca4f0334f6748afe910c3beda4063d38055e1716cbe2c551059f1b},ed:0xaf24f7c70000000000000000000000005a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c0000000000000000000000005a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c0000000000000000000000005a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c0000000000000000000000005a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c000}"
        guard let ciImage: CIImage = string.qrCode else {
            print("CIImage is not generated.")
            return
        }
        let qrImage: UIImage = UIImage(ciImage: ciImage)
        
        print(qrImage.readQRCode!)
    }
}
