//
//  SdkInteractDelegate.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 26/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

protocol SdkInteractDelegate: AnyObject {
    func handleInteractListner(_ eventHandler: EventHandler)
}
