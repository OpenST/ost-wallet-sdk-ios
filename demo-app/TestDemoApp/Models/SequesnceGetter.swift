/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk


class SequenceGetter {
  static let sharedInstance = SequenceGetter()
  static let queue = DispatchQueue(label: "SequenceGetter.queue", qos: .background, attributes: .concurrent)
  
  func getDeviceInLoop () {
    SequenceGetter.queue.asyncAfter(deadline: .now()+0.1) {
      if let userId = CurrentUserModel.getInstance.ostUserId {
        if let ostUser = OstWalletSdk.getUser(userId) {
          if let device = ostUser.getCurrentDevice() {
            print("device found : \(device.updatedTimestamp) ")
          }else {
            print("current device not found")
          }
        }else {
          print("current user not found")
        }
      }else {
        print("userId not found")
      }
      self.getDeviceInLoop()
    }
  }
}
