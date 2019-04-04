/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

protocol OstDataDefinitionWorkflow {
    
    /// Validate data defination dependent parameters.
    ///
    /// - Throws: OstError
    func validateApiDependentParams() throws
    
    /// Get context entity for provided data defination
    ///
    /// - Returns: OstContextEntity
    func getDataDefinitionContextEntity() -> OstContextEntity
    
    /// Get workflow context for provided data defination.
    ///
    /// - Returns: OstWorkflowContext
    func getDataDefinitionWorkflowContext() -> OstWorkflowContext
    
    /// Start data defination flow
    func startDataDefinitionFlow()
}
