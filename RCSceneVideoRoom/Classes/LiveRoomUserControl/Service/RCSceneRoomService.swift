//
//  RCSceneRoomService.swift
//  RCSceneVoiceRoom
//
//  Created by shaoshuai on 2022/2/26.
//

import Moya

class RCSceneRoomService {
    private lazy var provider = MoyaProvider<RCSRUserService>(plugins:[RCSServiceLogger])
    
    func roomUsers(roomId: String, completion: @escaping RCSCompletion) {
        provider.request(.roomUsers(roomId: roomId), completion: completion)
    }
    
    func follow(userId: String, completion: @escaping RCSCompletion) {
        provider.request(.follow(userId: userId), completion: completion)
    }
    
    func followList(page: Int, type: Int, completion: @escaping RCSCompletion) {
        let api = RCSRUserService.followList(page: page, type: type)
        provider.request(api, completion: completion)
    }
    
    func roomManagers(roomId: String, completion: @escaping RCSCompletion) {
        provider.request(.roomManagers(roomId: roomId), completion: completion)
    }
    
    func setRoomManager(roomId: String, userId: String, isManager: Bool, completion: @escaping RCSCompletion) {
        let api = RCSRUserService.setRoomManager(roomId: roomId,
                                                 userId: userId,
                                                 isManager: isManager)
        provider.request(api, completion: completion)
    }
}

enum RCSRUserService {
    case roomUsers(roomId: String)
    
    case follow(userId: String)
    case followList(page: Int, type: Int)
    
    case roomManagers(roomId: String)
    case setRoomManager(roomId: String, userId: String, isManager: Bool)
}

extension RCSRUserService: RCSServiceType {
    public var path: String {
        switch self {
        case let .roomUsers(roomId):
            return "mic/room/\(roomId)/members"
        case let .follow(userId):
            return "user/follow/\(userId)"
        case .followList:
            return "user/follow/list"
        case let .roomManagers(roomId):
            return "mic/room/\(roomId)/manage/list"
        case .setRoomManager:
            return "mic/room/manage"
        }
    }
    
    public var method: RCSMethod {
        switch self {
        case .setRoomManager:
            return .put
        default:
            return .get
        }
    }
    
    public var task: Task {
        switch self {
        case let .followList(page, type):
            return .requestParameters(parameters: ["size": 20, "page": page, "type": type],
                                      encoding: URLEncoding.default)
        case let .setRoomManager(roomId, userId, isManager):
            return .requestParameters(parameters: ["roomId": roomId, "userId": userId, "isManage": isManager], encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
}
