/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAddSessionQRHelper: OstSessionHelper {
	
	let sessionAddress: String
	init(userId: String,
		 sessionAddress: String,
		 expiresAfter: TimeInterval,
		 spendingLimit: String) {
		
		self.sessionAddress = sessionAddress
		super.init(userId: userId, expiresAfter: expiresAfter, spendingLimit: spendingLimit)
	}
	
	override func getNewSessionAddress() throws -> String {
        return sessionAddress
    }
}

