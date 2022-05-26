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
    public static func login(phone: String, success: @escaping (UserModel) -> Void, failure: @escaping FailureBlock) {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let api = RCLoginService.login(mobile: phone,
                                       code: "123456",
                                       userName: nil,
                                       portrait: nil,
                                       deviceId: deviceId,
                                       region: "+86",
                                       platform: "mobile")
        
        loginProvider.request(api) { result in
            switch result.map(RCSceneWrapper<User>.self) {
            case let .success(wrapper):
                if let user = wrapper.data {
                    UserDefaults.standard.set(user: user)
                    UserDefaults.standard.set(authorization: user.authorization)
                    UserDefaults.standard.set(rongCloudToken: user.imToken)
                    success(user.model)
                } else {
                    failure(wrapper.msg ?? "数据错误")
                }
            case let .failure(error):
                failure(error.localizedDescription)
            }
        }
    }
    
    @objc
    public static func rooms(success: @escaping ([RoomModel]) -> Void, failure: @escaping FailureBlock) {
        roomList { result in
            switch result {
            case let .success(items):
                success(items.map { $0.model })
            case let .failure(error):
                failure(error.localizedDescription)
            }
        }
    }
    
    static func roomList(type: Int = 3,
                  page: Int = 1,
                  size: Int = 20,
                  completion: @escaping (Result<[RCSceneRoom], NetError>) -> Void) {
        roomProvider.request(.roomList(type: type, page: page, size: size)) { result in
            switch result.map(RCSceneWrapper<VoiceRoomList>.self) {
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
