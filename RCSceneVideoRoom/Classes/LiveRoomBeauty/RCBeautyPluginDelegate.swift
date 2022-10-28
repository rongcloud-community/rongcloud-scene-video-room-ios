//
//  RCBeautyPlugin.swift
//  RCE
//
//  Created by shaoshuai on 2022/1/12.
//

import AVFoundation

public enum RCBeautyAction {
    case retouch
    case sticker
    case makeup
    case effect
}

public protocol RCBeautyPluginDelegate: AnyObject {
    func didOutput(_ frame: RCRTCVideoFrame) -> RCRTCVideoFrame
    func didClick(_ action: RCBeautyAction)
}
