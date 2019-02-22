//
//  OstConnectivity.swift
//  OstSdk
//
//  Created by aniket ayachit on 06/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import Alamofire

class OstConnectivity {
    class var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    class var isConnectedToWifi: Bool {
        return NetworkReachabilityManager()!.isReachableOnEthernetOrWiFi
    }
    
    class var isConnectedToWWAN: Bool {
        return NetworkReachabilityManager()!.isReachableOnWWAN
    }
}
