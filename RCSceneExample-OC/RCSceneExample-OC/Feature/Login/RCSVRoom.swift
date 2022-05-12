//
//  RCSVRoom.swift
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

import UIKit
import RCSceneVideoRoom

@objc
public class RCSVRoom: NSObject {
    @objc
    public static func show(_ nav: UINavigationController, room: RoomModel?) {
        let _ = VideoRoomCoordinator(rootViewController: nav)
        let controller = RCVideoRoomController(room: room?.room)
        nav.pushViewController(controller, animated: true)
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
            "isPrivate": isPrivate,
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
