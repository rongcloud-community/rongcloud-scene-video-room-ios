//
//  LiveRoomLiveType.swift
//  AFNetworking
//
//  Created by shaoshuai on 2022/9/5.
//

import RCLiveVideoLib

public typealias RCSLivePlayer = UIView & RCLiveVideoPlayer

public protocol RCSThirdCDNProtocol {
    func pushURLString(_ roomId: String) -> String
    func pullURLString(_ roomId: String) -> String
    func pullPlayer(_ roomId: String) -> RCSLivePlayer
}
