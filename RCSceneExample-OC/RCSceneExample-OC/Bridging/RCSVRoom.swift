//
//  RCSVRoom.swift
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

import RCSceneVideoRoom

@objc
public class RCSVRoom: NSObject {
    @objc
    public static func show(_ presenter: UIViewController, room: RoomModel?) {
        let controller = RCVideoRoomController(room: room?.room)
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .overFullScreen
        presenter.present(controller, animated: true)
    }
}
