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
    
    let userId: String = "123"
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try RegisterDevice(userId: userId).perform()
            
        }catch let error {
            print(error)
        }
    }
   
}
