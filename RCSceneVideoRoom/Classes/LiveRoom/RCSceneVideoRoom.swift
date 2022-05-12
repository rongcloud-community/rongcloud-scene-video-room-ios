//
//  RCSceneVideoRoom.swift
//  RCSceneVideoRoom
//
//  Created by shaoshuai on 2022/2/27.
//

import XCoordinator
import RCSceneRoom

public var kVideoRoomEnableCDN: Bool = true

public func RCVideoRoomController(room: RCSceneRoom? = nil,
                                  beautyPlugin: RCBeautyPluginDelegate? = nil) -> RCRoomCycleProtocol {
    if let room = room, room.userId != Environment.currentUserId {
        let controller = LiveVideoRoomViewController(room)
        controller.beautyPlugin = beautyPlugin
        return controller
    }
    
    let controller = LiveVideoRoomHostController(room)
    controller.beautyPlugin = beautyPlugin
    return controller
}

extension LiveVideoRoomHostController: RCRoomCycleProtocol {
}

extension LiveVideoRoomViewController: RCRoomCycleProtocol {
    func setRoomContainerAction(action: RCRoomContainerAction) {
        self.roomContainerAction = action
    }
    
    func joinRoom(_ completion: @escaping (Result<Void, RCSceneError>) -> Void) {
        self.videoJoinRoom(completion)
    }
    
    func setRoomFloatingAction(action: RCSceneRoomFloatingProtocol) {
        self.floatingManager = action
    }
    
    func leaveRoom(_ completion: @escaping (Result<Void, RCSceneError>) -> Void) {
        self.videoLeaveRoom(completion)
    }
    
    func descendantViews() -> [UIView] {
        return self.videoDescendantViews()
    }
}
