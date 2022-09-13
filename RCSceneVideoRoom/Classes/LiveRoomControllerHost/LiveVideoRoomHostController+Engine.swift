//
//  LiveVideoRoomHostController+Audio.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/27.
//

import UIKit
import CoreGraphics

struct managersWrapper: Codable {
    let code: Int
    let data: [RCSceneRoomUser]?
}

extension LiveVideoRoomHostController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func engine_viewDidLoad() {
        m_viewDidLoad()
        
        /// 视频码率对照表：https://support.rongcloud.cn/ks/MTA3OA==
        let config = RCRTCVideoStreamConfig()
        config.videoSizePreset = .preset1280x720
        config.videoFps = .FPS15
        config.minBitrate = 1540
        config.maxBitrate = 2200
        RCRTCEngine.sharedInstance().defaultVideoStream.videoConfig = config
        
        RCLiveVideoEngine.shared().prepare()
        RCLiveVideoEngine.shared().delegate = self
        RCLiveVideoEngine.shared().mixDelegate = self
        RCLiveVideoEngine.shared().mixDataSource = self
    }
    
    private func fetchManagers() {
        videoRoomService.roomManagers(roomId: room.roomId) { [weak self] result in
            switch result.map(managersWrapper.self) {
            case let .success(wrapper):
                guard let self = self else { return }
                self.managers = wrapper.data ?? []
            case let.failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

extension LiveVideoRoomHostController: LiveVideoRoomCreationDelegate {
    func didCreate(_ room: RCSceneRoom) {
        self.room = room
        roomDidCreated()
        
        self.rebuildLayout()
        self.setupMessageView()
        self.setupToolBarView()
        self.fetchManagers()
        
        let roomId = room.roomId
        /// 开启直播
        SVProgressHUD.show()
        RCLiveVideoEngine.shared().begin(room.roomId) { code in
            if code == .success {
                SVProgressHUD.dismiss()
                self.setupThirdCDN(roomId)
                RCRTCEngine.sharedInstance().defaultVideoStream.startCapture()
                videoRoomService.userUpdateCurrentRoom(roomId: roomId) { _ in }
            } else {
                SVProgressHUD.showError(withStatus: "开始直播失败：\(code.rawValue)")
            }
        }
        RCSensorAction.joinRoom(room, enableMic: true, enableCamera: true).trigger()
    }
    
    private func setupThirdCDN(_ roomId: String) {
        guard case .CDN(let third) = kCDNType else { return }
        RCLiveVideoEngine.shared().addThirdCDN(third.pushURLString(roomId)) { code in
            debugPrint("add third CDN path \(code.rawValue)")
        }
    }
}

extension LiveVideoRoomHostController: RCLiveVideoDelegate {
    func roomInfoDidSync() {
        roomUserView.setRoom(room)
    }
    
    func userDidKickOut(_ userId: String, byOperator operatorId: String) {
        handleKickOutRoom(userId, by: operatorId)
    }
    
    func didOutputFrame(_ frame: RCRTCVideoFrame) -> RCRTCVideoFrame {
        return beautyPlugin?.didOutput(frame) ?? frame
    }
    
    func liveVideoUserDidUpdate(_ userIds: [String]) {
        let liveUsers: [String] = userIds.filter { $0.count > 0 }
        
        switch RCLiveVideoEngine.shared().currentMixType {
        case .oneToOne:
            micButton.micState = liveUsers.count == 2 ? .connecting : .user
            setupMessageLayout(.oneToOne)
        default: micButton.micState = .user
        }
        
        SceneRoomManager.updateLiveSeatList()
        debugPrint("live video users: \(liveUsers)")
    }
    
    func liveVideoRequestDidChange() {
        RCLiveVideoEngine.shared().getRequests { [weak self] code, userIds in
            self?.micButton.setBadgeCount(userIds.count)
        }
    }
    
    func liveVideoInvitationDidAccept(_ userId: String) {
        switch RCLiveVideoEngine.shared().currentMixType {
        case .oneToOne:
            micButton.micState = .connecting
        default:
            micButton.micState = .user
        }
    }
    
    func liveVideoInvitationDidReject(_ userId: String) {
        RCSceneUserManager.shared.fetch([userId]) { users in
            guard let user = users.first else { return }
            SVProgressHUD.showInfo(withStatus: "\(user.userName)拒绝上麦")
        }
        micButton.micState = .user
    }
    
    func userDidEnter(_ userId: String, withUserCount count: Int) {
        handleUserEnter(userId)
        roomCountingView.update(count)
    }
    
    func userDidExit(_ userId: String, withUserCount count: Int) {
        handleUserExit(userId)
        roomCountingView.update(count)
    }
    
    func messageDidReceive(_ message: RCMessage) {
        handleReceivedMessage(message)
    }
    
    func network(_ delay: Int) {
        roomUserView.updateNetworking(rtt: delay)
    }
    
    func roomInfoDidUpdate(_ key: String, value: String) {
        switch key {
        case "shields":
            SceneRoomManager.shared.forbiddenWords = value.decode([])
        case "FreeEnterSeat":
            isSeatFreeEnter = value == "1"
        case "RCRTCVideoResolution":
            videoPropsSetVc.setupPreset(value)
        case "RCRTCVideoFps":
            videoPropsSetVc.setupFPS(value)
        default: ()
        }
    }
    
    func roomMixTypeDidChange(_ mixType: RCLiveVideoMixType) {
        layoutLiveVideoView(mixType)
        if mixType == .gridTwo || mixType == .gridThree {
            RCLiveVideoEngine.shared().currentSeats.forEach {
                $0.enableTiny = false
            }
        }
        seatView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func roomDidClosed() {
        backTrigger()
    }
}

extension LiveVideoRoomHostController: RCLiveVideoMixDataSource {
    func liveVideoPreviewSize() -> CGSize {
        return CGSize(width: 720, height: 1280)
    }
    
    func liveVideoFrames() -> [NSValue] {
        return [
            NSValue(cgRect: CGRect(x: 0.2500, y: 0.0000, width: 0.5000, height: 0.5000)),
            NSValue(cgRect: CGRect(x: 0.0000, y: 0.5000, width: 0.5000, height: 0.5000)),
            NSValue(cgRect: CGRect(x: 0.5000, y: 0.5000, width: 0.5000, height: 0.5000)),
        ]
    }
}

extension LiveVideoRoomHostController: RCLiveVideoMixDelegate {
    func liveVideoDidLayout(_ seat: RCLiveVideoSeat, withFrame frame: CGRect) {
        if RCLiveVideoEngine.shared().pkInfo != nil { return }
        guard let room = room else { return }
        let tag = seat.index + 10000
        seatView.viewWithTag(tag)?.removeFromSuperview()
        if RCLiveVideoEngine.shared().currentMixType == .oneToOne {
            if seat.userId.count == 0 { return }
        }
        let view = RCLiveVideoSeatItemView(room, seatInfo: seat)
        seatView.addSubview(view)
        view.frame = frame
        view.tag = tag
    }
    
    func roomMixConfigWillUpdate(_ config: RCRTCMixConfig) {
    }
}

extension VideoPropertiesSetViewController {
    func setupPreset(_ value: String) {
        let items: [String] = ["480X480", "640X480", "720X480", "1280X720"]
        if let index = items.firstIndex(of: value) {
            selectSectionIndexPath[0] = IndexPath(item: index, section: 0)
        }
    }
    
    func setupFPS(_ value: String) {
        let items: [String] = ["10", "15", "24", "30"]
        if let index = items.firstIndex(of: value) {
            selectSectionIndexPath[1] = IndexPath(item: index, section: 1)
        }
    }
}

extension String {
    func decode<T: Codable>(_ empty: T) -> T {
        guard let data = data(using: .utf8) else { return empty }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return empty
        }
    }
}
