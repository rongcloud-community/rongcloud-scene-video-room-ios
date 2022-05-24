//
//  LiveVideoRoomHostController+Settings.swift
//  RCE
//
//  Created by shaoshuai on 2021/9/27.
//

import RCSceneRoom

extension LiveVideoRoomHostController {
 
    @_dynamicReplacement(for: m_viewDidLoad)
    private func settings_viewDidLoad() {
        m_viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleNoticeDidTap))
        roomNoticeView.addGestureRecognizer(tap)
    }
    
    @objc func handleNoticeDidTap() {
        let notice = room.notice ?? "欢迎来到\(room.roomName)"
        let vc = NoticeViewController(false, notice: notice, delegate: self)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.hidesBottomBarWhenPushed = true
        present(vc, animated: true)
    }
    
    @objc func handleSettingClick() {
        let notice = room.notice ?? "欢迎来到\(room.roomName)"
        let words = SceneRoomManager.shared.forbiddenWords
        let items: [Item] = {
            return [
                .roomLock(room.isPrivate == 0),
                .roomName(room.roomName),
                .roomNotice(notice),
                .forbidden(words),
                .cameraSwitch,
                .beautySticker,
                .beautyRetouch,
                .beautyMakeup,
                .beautyEffect,
                .seatFree(!isSeatFreeEnter),
                .music,
                .cameraSetting
            ]
        }()
        let controller = RCSRSettingViewController(items: items, delegate: self)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
    }
    
    private func setRoomType(isPrivate: Bool, password: String?) {
        let title = isPrivate ? "设置房间密码" : "解锁"
        func onSuccess() {
            SVProgressHUD.showSuccess(withStatus: "已\(title)")
            room.isPrivate = isPrivate ? 1 : 0
        }
        func onError() {
            SVProgressHUD.showError(withStatus: title + "失败")
        }
        videoRoomService.setRoomType(roomId: room.roomId, isPrivate: isPrivate, password: password) { result in
            switch result.map(RCSceneResponse.self) {
            case let .success(response):
                if response.validate() {
                    onSuccess()
                } else {
                    onError()
                }
            case .failure: onError()
            }
        }
    }
}

extension LiveVideoRoomHostController: RCSceneRoomSettingProtocol {
    func eventWillTrigger(_ item: Item) -> Bool {
        RCSensorAction.settingClick(room, item: item).trigger()
        return false
    }
    
    func eventDidTrigger(_ item: Item, extra: String?) {
        switch item {
        case .roomLock(let lock):
            setRoomType(isPrivate: lock, password: extra)
        case .roomName(let name):
            roomUpdate(name: name)
        case .roomNotice(let notice):
            roomUpdate(notice: notice)
        case .music:
            presentMusicController()
        case let .forbidden(words):
            forbiddenWordsDidChange(words)
        case .seatFree(let free):
            freeMicDidClick(isFree: free)
        case .cameraSetting:
            present(videoPropsSetVc, animated: true)
        case .cameraSwitch:
            switchCameraDidClick()
        case .beautyRetouch:
            beautyPlugin?.didClick(.retouch)
        case .beautySticker:
            beautyPlugin?.didClick(.sticker)
        case .beautyMakeup:
            beautyPlugin?.didClick(.makeup)
        case .beautyEffect:
            beautyPlugin?.didClick(.effect)
        default: ()
        }
    }
}

//MARK: - Voice Room Setting Delegate
extension LiveVideoRoomHostController {
    
    func switchCameraDidClick() {
        RCRTCEngine.sharedInstance().defaultVideoStream.switchCamera()
        let postion = RCRTCEngine.sharedInstance().defaultVideoStream.cameraPosition
        let needMirror = postion == .captureDeviceFront
        RCRTCEngine.sharedInstance().defaultVideoStream.isEncoderMirror = needMirror
        RCRTCEngine.sharedInstance().defaultVideoStream.isPreviewMirror = needMirror
    }
    
    func freeMicDidClick(isFree: Bool) {
        isSeatFreeEnter = isFree
        let value: String = isFree ? "1" : "0"
        RCLiveVideoEngine.shared().setRoomInfo(["FreeEnterSeat": value]) { code in
            debugPrint("setRoomInfo \(code.rawValue)")
        }
        if isSeatFreeEnter {
            SVProgressHUD.showSuccess(withStatus: "当前可自由上麦")
        } else {
            SVProgressHUD.showSuccess(withStatus: "当前需申请上麦")
        }
    }
}

extension LiveVideoRoomHostController: VideoPropertiesDelegate {
    func videoPropertiesDidChanged(_ resolutionRatio: ResolutionRatio, fps: Int, bitRate: Int) {
        let config = RCRTCVideoStreamConfig()
        config.videoSizePreset = {
            switch resolutionRatio {
            case .video640X480P:
                return .preset640x480
            case .video720X480P:
                return .preset720x480
            case .video1280X720P:
                return .preset1280x720
            case .video1920X1080P:
                return .preset1920x1080
            }
        }()
        config.videoFps = {
            switch fps {
            case 10: return .FPS10
            case 15: return .FPS15
            case 24: return .FPS24
            case 30: return .FPS30
            default: return .FPS15
            }
        }()
        config.minBitrate = UInt(bitRate / 10 * 7)
        config.maxBitrate = UInt(bitRate)
        RCRTCEngine.sharedInstance().defaultVideoStream.videoConfig = config
        
        let roomInfo: [String: String] = [
            "RCRTCVideoResolution": resolutionRatio.rawValue,
            "RCRTCVideoFps": "\(fps)"
        ]
        RCLiveVideoEngine.shared().setRoomInfo(roomInfo) { _ in }
    }
}

// MARK: - Modify Room Name Delegate
extension LiveVideoRoomHostController {
    func roomUpdate(name: String) {
        videoRoomService.setRoomName(roomId: room.roomId, name: name) { [weak self] result in
            switch result.map(RCSceneResponse.self) {
            case let .success(response):
                if response.validate() {
                    self?.didUpdateRoomName(name)
                    SVProgressHUD.showSuccess(withStatus: "更新房间名称成功")
                } else {
                    SVProgressHUD.showError(withStatus: response.msg ?? "更新房间名称失败")
                }
            case .failure:
                SVProgressHUD.showError(withStatus: "更新房间名称失败")
            }
        }
    }
    
    private func didUpdateRoomName(_ name: String) {
        room.roomName = name
        RCLiveVideoEngine.shared().setRoomInfo(["name": name]) { _ in }
    }
    
    func roomUpdate(notice: String) {
        LiveNoticeChecker.check(notice) { pass, msg in
            if (pass) {
                /// 本地更新
                self.room.notice = notice
                /// 远端更新
                RCLiveVideoEngine.shared().setRoomInfo(["notice": notice]) { _ in }
                
                /// 本地公屏消息
                let message = RCTextMessage(content: "房间公告已更新")!
                ChatroomSendMessage(message) { result in
                    switch result {
                    case .success:
                        self.messageView.addMessage(message)
                    case .failure(let error):
                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                    }
                }
            } else {
                SVProgressHUD.showError(withStatus: msg);
            }
        }
    }
}

extension LiveVideoRoomHostController {
    func forbiddenWordsDidChange(_ words: [String]) {
        if SceneRoomManager.shared.forbiddenWords == words { return }
        SceneRoomManager.shared.forbiddenWords = words
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: words, options: .fragmentsAllowed)
            if let json = String(data: jsonData, encoding: .utf8) {
                RCLiveVideoEngine.shared().setRoomInfo(["shields": json]) { code in
                    debugPrint("setRoomInfo \(code.rawValue)")
                }
            }
        } catch {
            debugPrint("setRoomInfo \(error.localizedDescription)")
        }
    }
}
