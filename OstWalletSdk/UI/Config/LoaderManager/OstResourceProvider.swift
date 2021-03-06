/*
Copyright © 2019 OST.com Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
*/

import Foundation

class OstResourceProvider: NSObject {
	static var appLoaderMangerObj: OstLoaderDelegate? = nil
	
	@objc
	class func setApplicationLoaderManager(_ manager: OstLoaderDelegate) {
		appLoaderMangerObj = manager
	}
	
	@objc
	class func getLoaderManger() -> OstLoaderDelegate {
		return (nil != appLoaderMangerObj) ? appLoaderMangerObj! : OstLoaderManager.shared
	}
	
	@objc
	class func getOstLoaderManager() -> OstLoaderDelegate {
		return OstLoaderManager.shared
	}
}
