//
//  SceneRoomManager+LiveExtension.swift
//  RCE
//
//  Created by shaoshuai on 2021/12/8.
//

import RCSceneRoom

extension SceneRoomManager {
    static func updateLiveSeatList() {
        shared.seats = RCLiveVideoEngine
            .shared()
            .currentSeats
            .map { $0.userId }
    }
}
