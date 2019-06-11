/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk


struct OstNotificationModel {
    let workflowContext: OstWorkflowContext
    var contextEntity: OstContextEntity? = nil
    var error: OstError? = nil
}

class OstNotificationManager {
    static let getInstance = OstNotificationManager()
    private init () { }

    var notificationView: OstNotification? = nil
    
    var notifications: [OstNotificationModel] = [OstNotificationModel]()
    
    //MARK: - Functions
    func show(withWorkflowContext workflowContext : OstWorkflowContext,
              contextEntity: OstContextEntity? = nil,
              error: OstError? = nil) {
        
        let model = OstNotificationModel(workflowContext: workflowContext,
                                         contextEntity: contextEntity,
                                         error: error)
        self.show(withNotificaion: model)
    }
    
    
    func show(withNotificaion notificationModel: OstNotificationModel) {
        if canShowNotification(notificationModel: notificationModel) {
            notifications.append(notificationModel)
        }
        showNext()
    }
    
   
    func canShowNotification(notificationModel: OstNotificationModel) -> Bool {

        let workflowContext = notificationModel.workflowContext
        if let error = notificationModel.error,
            error.messageTextCode == .userCanceled {
            
            return false
        }
        
        if workflowContext.workflowType == .activateUser {
            return true
        }
        
        if workflowContext.workflowType == .executeTransaction {
            return true
        }
        
        return false
    }
    
    func showNext() {
        if nil == notificationView,
            let notificationModel: OstNotificationModel = notifications.first {
            
            if nil != notificationModel.contextEntity {
                notificationView = OstSuccessNotification()
                notificationView?.notificationModel = notificationModel
            }else if nil != notificationModel.error {
                notificationView = OstErroNotification()
                notificationView?.notificationModel = notificationModel
            }
            
            if nil != notificationView {
                removeFirstNotificationModel()
                showNotificaiton()
            }else {
                showNext()
            }
        }
    }
    
    private func showNotificaiton() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
            if let strongSelf = self,
                let notificaitonV = strongSelf.notificationView {
                    notificaitonV.show(onCompletion: {[weak self] (isCompleted) in
                        if isCompleted {
                            self?.removeNotificationAfterDelay()
                        }else {
                            self?.removeNotification()
                        }
                    })
            }else {
                self?.removeNotification()
            }
        }
    }
    
    func removeNotificationAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {[weak self] in
            self?.removeNotification()
        })
    }
    
    func removeNotification() {
        if nil != notificationView {
            notificationView!.hide(onCompletion: {[weak self] (isComplete) in
                self?.notificationView = nil
                self?.showNext()
            })
        }else {
            notificationView = nil
            showNext()
        }
    }
    
    func removeFirstNotificationModel() {
        if notifications.count > 0 {
            notifications.remove(at: 0)
        }
    }
    
    func removeAllNotificationModels() {
        notifications.removeAll()
    }
}
