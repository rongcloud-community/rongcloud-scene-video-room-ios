//
//  UserDefault+Extension.swift
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/19.
//

import Foundation

@objc
extension UserDefaults {
    func oc_rongToken() -> String? {
        return UserDefaults.standard.rongToken()
    }
    
    func oc_authorizationKey() -> String? {
        return UserDefaults.standard.authorizationKey()
    }
    
    func oc_set(authorization: String) {
        UserDefaults.standard.set(authorization: authorization)
    }
    
    func oc_set(rongCloudToken: String) {
        UserDefaults.standard.set(rongCloudToken: rongCloudToken)
    }
    
    func oc_clearLoginStatus() {
        UserDefaults.standard.clearLoginStatus()
    }
    
    func oc_shouldShowFeedback() -> Bool {
        return UserDefaults.standard.shouldShowFeedback()
    }
    
    func oc_increaseFeedbackCountdown() {
        UserDefaults.standard.increaseFeedbackCountdown()
    }
    
    func oc_feedbackCompletion() {
        UserDefaults.standard.feedbackCompletion()
    }
  
    func oc_clearCountDown() {
        UserDefaults.standard.clearCountDown()
    }
    
    func oc_set(fraudProtectionTriggerDate:Date) {
        UserDefaults.standard.set(fraudProtectionTriggerDate: fraudProtectionTriggerDate)
    }
    
    func oc_fraudProtectionTriggerDate() -> Date? {
        return UserDefaults.standard.fraudProtectionTriggerDate()
    }
}
