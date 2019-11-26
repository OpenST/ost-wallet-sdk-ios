/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstLoaderManager: NSObject, OstLoaderDelegate {

  static let shared: OstLoaderDelegate = OstLoaderManager();
  
  @objc
  func getLoader(workflowType: OstWorkflowType) -> OstWorkflowLoader? {
    return OstLoaderIndicator.getInstance(workflowType: workflowType)
  }
   
  @objc
  func waitForFinalization(workflowType: OstWorkflowType) -> Bool {  
    return false
  }
}
