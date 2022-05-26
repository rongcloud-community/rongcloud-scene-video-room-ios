//
//  LiveVideoRoomHostController+ToolBar.swift
//  RCE
//
//  Created by shaoshuai on 2021/10/29.
//

import UIKit

extension LiveVideoRoomHostController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func toolBar_viewDidLoad() {
        m_viewDidLoad()
        micButton.addTarget(self, action: #selector(liveVideoRequestDidClick), for: .touchUpInside)
        giftButton.addTarget(self, action: #selector(handleGiftButtonClick), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(handleMessageButtonClick), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(handleSettingClick), for: .touchUpInside)
        messageButton.refreshMessageCount()
    }
    
    func setupToolBarView() {
        messageButton.refreshMessageCount()
        micButton.micState = .user
        chatroomView.toolBar.delegate = self
        let config = RCChatroomSceneToolBarConfig.default()
        config.commonActions = [micButton]
        config.actions = [pkButton, giftButton, messageButton, settingButton]
        config.recordButtonEnable = false
        chatroomView.toolBar.setConfig(config)
    }
    
    @objc func handleMessageButtonClick() {
        RCSensorAction.textClick(room).trigger()
        ChatListViewController.presenting(self)
    }
}

extension LiveVideoRoomHostController: RCChatroomSceneToolBarDelegate {
    func textInputViewSendText(_ text: String) {
        RCSceneUserManager.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
            let event = RCChatroomBarrage()
            event.userId = user.userId
            event.userName = user.userName
            event.content = text
            self?.messageView.addMessage(event)
            if text.isCivilized {
                RCLiveVideoEngine.shared().sendMessage(event) { code in
                    debugPrint(code)
                }
            }
        }
    }
    
    func audioRecordShouldBegin() -> Bool {
        if RCCoreClient.shared().isAudioHolding() {
            SVProgressHUD.showError(withStatus: "声音通道被占用，请下麦后使用")
            return false
        }
        return true
    }
    
    func audioRecordDidEnd(_ data: Data?, time: TimeInterval) {
        guard let data = data, time > 1 else { return SVProgressHUD.showError(withStatus: "录音时间太短") }
        videoRoomService.uploadAudio(data: data, extensions: "wav") { [weak self] result in
            switch result.map(RCSceneWrapper<String>.self) {
            case let .success(response):
                guard let path = response.data else {
                    SVProgressHUD.showError(withStatus: "文件上传失败")
                    return
                }
                let urlString = Environment.url.absoluteString + "/file/show?path=" + path
                self?.sendMessage(urlString, time: Int(time) + 1)
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func sendMessage(_ URLString: String, time: Int) {
        RCSceneUserManager.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
            let message = RCVRVoiceMessage()
            message.userId = user.userId
            message.userName = user.userName
            message.path = URLString
            message.duration = UInt(time)
            ChatroomSendMessage(message) { result in
                switch result {
                case .success:
                    self?.messageView.addMessage(message)
                case .failure(let error):
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
            }
        }
    }
    
}
