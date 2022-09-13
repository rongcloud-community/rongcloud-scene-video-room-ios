//
//  LiveRoomLiveType.swift
//  AFNetworking
//
//  Created by shaoshuai on 2022/9/5.
//

import RCLiveVideoLib

public typealias RCSLivePlayerView = UIView & RCSLivePlayer

public protocol RCSThirdCDNProtocol {
    func pushURLString(_ roomId: String) -> String
    func pullURLString(_ roomId: String) -> String
    func pullPlayer(_ roomId: String) -> RCSLivePlayerView
}

public enum RCSCDNType {
    case MCU
    case CDN_WS
    case CDN(RCSThirdCDNProtocol)
}
