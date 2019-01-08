//
//  OSTBaseEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OSTBaseEntity: NSObject {
    
    enum EntityErrors: Error {
        case validationError(String)
    }
    
    public static let ID = "id"
    public static let PARENT_ID = "parent_id"
    public static let DATA = "data"
    public static let STATUS = "status"
    public static let UTS = "uts"
    
    public static let DEFAULTSTATUS = "ACTIVE"
    
    public private(set) var id: String = String(Date.negativeTimestamp())
    public private(set) var parnet_id: String = "-1"
    internal private(set) var data: [String: Any] = ["id": String(Date.negativeTimestamp())]
    internal private(set) var baseStatus: String = OSTBaseEntity.DEFAULTSTATUS
    public private(set) var uts: String = String(Date.negativeTimestamp())
    
    
    func getStringVal(_ val: Any?) -> String? {
        if (val is String){
            return (val as! String)
        }else if (val is Int){
           return String(val as! Int)
        }
        return nil
    }
    
    //MARK: - validate
    func validJSON(_ json: [String: Any]) -> (Bool, String?) {
        var isValidJSON: Bool = false
        let idVal: String? = getStringVal(json[OSTBaseEntity.ID])
        if (idVal != nil) {
            isValidJSON = isValidID(idVal!)
            if !isValidJSON {
                return (isValidJSON, "id is not valid")
            }
        }else{
            return (false, "id is missing")
        }
        
        let parentIdVal: String? = getStringVal(json[OSTBaseEntity.PARENT_ID])
        if (parentIdVal != nil) {
            isValidJSON = isValidParnetId(parentIdVal!)
            if !isValidJSON {return (isValidJSON,"parent_id is not valid")}
        }else if (parentIdVal == nil && json[OSTBaseEntity.PARENT_ID] != nil){
            return (false, "parent_id is not valid")
        }
        
        let statusVal: String? = getStringVal(json[OSTBaseEntity.STATUS])
        if (statusVal != nil){
            isValidJSON = isValidStatus(statusVal!)
            if !isValidJSON {return (isValidJSON, "status is not valid")}
        }else if (statusVal == nil && json[OSTBaseEntity.STATUS] != nil){
            return (false, "status is not valid")
        }
        
        let utsVal: String? = getStringVal(json[OSTBaseEntity.UTS])
        if (utsVal != nil){
            isValidJSON = isValidUTS(utsVal!)
            if !isValidJSON {return (isValidJSON,"uts is not valid")}
        }else if (utsVal == nil && json[OSTBaseEntity.UTS] != nil){
            return (false, "uts is not valid")
        }
        
        return (isValidJSON, nil)
    }
    
    fileprivate func isValidID(_ id: String) -> Bool {
        return id.isAlphanumeric
    }
    
    fileprivate func isValidParnetId(_ parnetId: String) -> Bool {
        if (parnetId.isEmpty){
            return true
        }
        return parnetId.isAlphanumeric
    }
    
    fileprivate func isValidUTS(_ uts: String) -> Bool {
        return (Int(uts) != nil)
    }
    
    func isValidStatus(_ status: String) -> Bool {
        if (status.isEmpty){
            return true
        }
        return ["active", "inactive"].contains(status.lowercased())
    }
    
    //MARK: - set properties
    func setJsonValues(_ jsonValues: [String: Any]) {
        self.id = getStringVal(jsonValues[OSTBaseEntity.ID])!
        
        let parentID: String? = getStringVal(jsonValues[OSTBaseEntity.PARENT_ID])
        if (parentID != nil){
            self.parnet_id = parentID!
        }
        
        self.data = (jsonValues[OSTBaseEntity.DATA] != nil) ? jsonValues[OSTBaseEntity.DATA] as! [String: Any]: jsonValues
        
        let stauts: String? = getStringVal(jsonValues[OSTBaseEntity.STATUS])
        if (stauts != nil){
            self.baseStatus = stauts!
        }
        
        let uts: String? = getStringVal(jsonValues[OSTBaseEntity.UTS])
        if (uts != nil){
            self.uts = uts!
        }
    }
    
}
