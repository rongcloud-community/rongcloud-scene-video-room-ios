//
//  AppModel.swift
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/19.
//

import RCSceneRoom

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

extension RoomModel {
    var room: RCSceneRoom? {
        let desc: [String: Any] = [
            "id": id,
            "roomId": roomId,
            "roomName": roomName,
            "themePictureUrl": themePictureUrl ?? "",
            "backgroundUrl": backgroundUrl ?? "",
            "isPrivate": isPrivate ? 1 : 0,
            "password": password ?? "",
            "userId": userId,
            "createUser": [
                "userId": createUser?.userId ?? "",
                "userName": createUser?.userName ?? "",
                "portrait": createUser?.portrait ?? "",
                "status": createUser?.status ?? 0,
            ],
            "userTotal": userTotal,
            "roomType": roomType,
            "stop": stop,
            "notice": notice ?? "",
            "updateDt": 0
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: desc as NSDictionary,
                                                  options: .fragmentsAllowed)
            return try JSONDecoder().decode(RCSceneRoom.self, from: data)
        } catch {
            return nil
        }
    }
}
