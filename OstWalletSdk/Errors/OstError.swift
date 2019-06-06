/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc public class OstError: NSError {
    private static let ERROR_DOMAIN = "OstSdkError";
    @objc public internal(set) var isApiError = false
    @objc public var internalCode: String = ""
    @objc public let errorMessage:String
    public let messageTextCode:OstErrorCodes.OstErrorCode;
    
    @objc
    override public var description: String {
        return errorMessage
    }
    
    @objc
    public func getMessageTextCode() -> String {
        return OstErrorCodes.getErrorMessage(errorCode: messageTextCode);
    }
    
    @objc
    public var errorInfo: [String: Any]? = nil

    @objc
    public convenience init(internalCode: String, errorCode: OstErrorCodes.OstErrorCode, errorInfo:[String:Any]? = nil) {
        self.init(internalCode, errorCode, errorInfo);
    }
    
    public init(_ code: String, _ messageTextCode: OstErrorCodes.OstErrorCode, _ errorInfo:[String:Any]? = nil) {
        self.errorMessage = OstErrorCodes.getErrorMessage(errorCode: messageTextCode);
        self.messageTextCode = messageTextCode;
        self.internalCode = code;
        self.errorInfo = errorInfo;
        super.init(domain: OstError.ERROR_DOMAIN,
                   code:  messageTextCode.hashValue,
                   userInfo: OstError.toUserInfo(errorMessage: self.errorMessage,
                                                 messageTextCode: self.messageTextCode,
                                                 internalCode: self.internalCode,
                                                 errorInfo: self.errorInfo));
    }
    
    @objc
    public init(fromApiResponse response: [String: Any]) {
        let err = response["err"] as! [String: Any]
        self.errorMessage = err["msg"] as! String
        self.messageTextCode = .apiResponseError;
        self.internalCode = err["code"] as! String
        self.errorInfo = response
        self.isApiError = true
        let errorCode = OstErrorCodes.getStringErrorCode(errorCode: messageTextCode);
        super.init(domain: OstError.ERROR_DOMAIN,
                   code:  messageTextCode.hashValue,
                   userInfo: OstError.toUserInfo(errorMessage: self.errorMessage,
                                                 errorCode: errorCode,
                                                 internalCode: self.internalCode,
                                                 errorInfo: self.errorInfo,
                                                 isApiError: self.isApiError,
                                                 apiError: err));
    }
    
    @objc public class OstJSONErrorKeys: NSObject {
        @objc public static let errorCode = "error_code";
        @objc public static let internalErrorCode = "internal_error_code";
        @objc public static let errorMessage = "error_message";
        @objc public static let errorInfo = "error_info";
        @objc public static let isApiError = "is_api_error";
        @objc public static let apiError = "api_error";
    }
    
    class func toUserInfo(errorMessage: String,
                          messageTextCode: OstErrorCodes.OstErrorCode,
                          internalCode: String,
                          errorInfo: [String: Any]? = nil,
                          isApiError: Bool = false) -> [String: Any] {
        let errorCode = OstErrorCodes.getStringErrorCode(errorCode: messageTextCode);
        return toUserInfo(errorMessage: errorMessage,
                          errorCode: errorCode,
                          internalCode: internalCode,
                          errorInfo: errorInfo,
                          isApiError: isApiError,
                          apiError: nil
        );
    }
    
    @objc public class func toUserInfo(errorMessage: String,
                          errorCode: String,
                          internalCode: String,
                          errorInfo: [String: Any]? = nil,
                          isApiError: Bool = false,
                          apiError: [String:Any]? = nil) -> [String: Any] {
        var userInfo: [String: Any] = [:];
        userInfo[OstJSONErrorKeys.errorMessage] = errorMessage;
        userInfo[OstJSONErrorKeys.errorCode] = errorCode;
        userInfo[OstJSONErrorKeys.internalErrorCode] = internalCode;
        userInfo[OstJSONErrorKeys.isApiError] = isApiError;
        if ( nil != errorInfo ) {
            userInfo[OstJSONErrorKeys.errorInfo] = errorInfo!;
        }
        if ( nil != apiError ) {
            userInfo[OstJSONErrorKeys.apiError] = apiError;
        }
        return userInfo;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension String {
    func snakeCased() -> String? {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.count)
        let snakeCasedString = regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2").lowercased()
        return snakeCasedString?.uppercased()
    }
}
