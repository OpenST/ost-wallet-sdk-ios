/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc public protocol OstLoaderDelegate: AnyObject {
  
  /// Get custom loader to show while workflow is in progress
  /// - Parameter workflowType: OstWorkflowType
  @objc
  func getLoader(workflowType: OstWorkflowType) -> OstWorkflowLoader?
  
  /// Check whether workflow should wait till finalization
  /// - Parameter workflowType: OstWorkflowType
  /// - Returns: Boolean
  @objc
  func waitForFinalization(workflowType: OstWorkflowType) -> Bool
}
