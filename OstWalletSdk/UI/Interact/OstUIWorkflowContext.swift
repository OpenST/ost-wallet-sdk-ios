/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
*/

import UIKit

@objc public class OstUIWorkflowContext: OstWorkflowContext {
    let uiWorkflowId: String;
    
    @objc public init(context: OstWorkflowContext, uiWorkflowId: String) {
        self.uiWorkflowId = uiWorkflowId;
        super.init(workflowId: context.getWorkflowId(), workflowType: context.workflowType);
    }
    
    @objc public override func getWorkflowId() -> String {
        return self.uiWorkflowId;
    }
    
    @objc public func getBaseWorkflowId() -> String {
        return super.getWorkflowId();
    }

}
