//
//  RCVideoRoomService.swift
//  RCSceneExample
//
//  Created by shaoshuai on 2022/3/29.
//

import Foundation
import RCSceneRoom

public typealias FailureBlock = (String) -> ()

struct VoiceRoomList: Codable {
    let totalCount: Int
    let rooms: [RCSceneRoom]
    let images: [String]
}

@objc
public class RCVideoRoomService: NSObject {
    @objc
    public func login(phone: String, success: @escaping (UserModel) -> Void, failure: @escaping FailureBlock) {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let api = RCLoginService.login(mobile: phone,
                                       code: "123456",
                                       userName: nil,
                                       portrait: nil,
                                       deviceId: deviceId,
                                       region: "+86",
                                       platform: "mobile")
        
        loginProvider.request(api) { result in
            switch result.map(RCNetworkWrapper<User>.self) {
            case let .success(wrapper):
                let user = wrapper.data!
                UserDefaults.standard.set(user: user)
                UserDefaults.standard.set(authorization: user.authorization)
                UserDefaults.standard.set(rongCloudToken: user.imToken)
                success(user.model)
            case let .failure(error):
                failure(error.localizedDescription)
            }
        }
    }
    
    @objc
    public func rooms(success: @escaping ([RoomModel]) -> Void, failure: @escaping FailureBlock) {
        roomList { result in
            switch result {
            case let .success(items):
                success(items.map { $0.model })
            case let .failure(error):
                failure(error.localizedDescription)
            }
        }
    }
    
    func roomList(type: Int = 3,
                  page: Int = 1,
                  size: Int = 20,
                  completion: @escaping (Result<[RCSceneRoom], NetError>) -> Void) {
        roomProvider.request(.roomList(type: type, page: page, size: size)) { result in
            switch result.map(RCNetworkWrapper<VoiceRoomList>.self) {
            case let .success(wrapper):
                if let list = wrapper.data {
                    SceneRoomManager.shared.backgrounds = list.images
                    completion(.success(list.rooms))
                } else {
                    completion(.failure(NetError("加载失败")))
                }
            case let .failure(error):
                completion(.failure(NetError(error.localizedDescription)))
            }
        }
    }
}

extension RCSceneRoom {
    var model: RoomModel {
        let roomModel = RoomModel()
        
        roomModel.id = id
        roomModel.roomId = roomId
        roomModel.roomName = roomName
        roomModel.themePictureUrl = themePictureUrl
        roomModel.backgroundUrl = backgroundUrl
        roomModel.password = password
        roomModel.userId = userId
        roomModel.notice = notice
        
        roomModel.isPrivate = isPrivate == 0
        roomModel.stop = stop
        roomModel.userTotal = userTotal
        roomModel.roomType = roomType ?? 1
        
        roomModel.createUser = createUser?.model
        
        return roomModel
    }
}

extension RCSceneRoomUser {
    var model: RoomUserModel {
        let roomUserModel = RoomUserModel()
        roomUserModel.userId = userId
        roomUserModel.userName = userName
        roomUserModel.portrait = portrait
        roomUserModel.status = status ?? 0
        return roomUserModel
    }
}

extension User {
    var model: UserModel {
        let userModel = UserModel()
        userModel.userId = userId
        userModel.userName = userName
        userModel.portrait = portrait ?? ""
        userModel.imToken = imToken
        userModel.authorization = authorization
        userModel.type = type
        return userModel
    }
}

@objc
extension UserDefaults {
    func oc_rongToken() -> String? {
        return UserDefaults.standard.rongToken()
    }
    
    func oc_authorizationKey() -> String? {
        return UserDefaults.standard.oc_authorizationKey()
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
