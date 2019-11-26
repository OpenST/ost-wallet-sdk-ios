/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

@objc
public class OstMockLoaderManager: NSObject, OstLoaderDelegate {
	
    //MARK: - OstLoaderDelegate
	@objc
  public func getLoader(workflowType: OstWorkflowType) -> OstWorkflowLoader? {
        return  OstMockLoaderViewController()
    }
    
	@objc
  public func waitForFinalization(workflowType: OstWorkflowType) -> Bool {
        if OstWorkflowType.executeTransaction == workflowType {
            return false
        }
        
        return true
    }
}
